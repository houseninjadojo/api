# frozen_string_literal: true

require 'net/http'
require 'uri'

# Decode and Verify JSON Web Tokens (JWT)
#
# @example
#   jwt = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6InZZblRMYUUwdnNESGNONFlqRTk1d..."
#   payload = JSONWebToken.verify(token: jwt)
#   => #<OpenStruct iss="https://auth.houseninja.co/", sub="auth0|617c94bb89cc8e0070dcf1...>

class JSONWebToken
  HEADER_REGEX = /\ABearer\s([a-zA-Z0-9\-\_\~\+\\]+\.[a-zA-Z0-9\-\_\~\+\\]+\.[a-zA-Z0-9\-\_\~\+\\]*)\z/
  CACHE_NAMESPACE = 'jwt'

  class << self
    # Decode and Verify a JWT
    #
    # This method caches the token until its expiration date after the first decoding.
    # Successive reads return the cached payload instead of running the decoding scheme every time.
    #
    # @param {String} token
    # @return {OpenStruct} token_payload
    def verify(token:)
      cached = fetch_cached_token(token)
      if cached.present?
        return cached
      end

      decoded_token = decode(token)
      if decoded_token.nil?
        return nil
      end

      payload = token_payload(decoded_token)

      write_cached_token(token, payload)
      return payload
    end

    def decode(token)
      begin
        decoded = JWT.decode(token, nil, true, **decoder_options) do |header|
          jwks_hash[header['kid']]
        end
        return decoded
      rescue JWT::ExpiredSignature, JWT::InvalidIatError
        # Expired
        # puts "EXPIRED"
        return nil
      rescue JWT::InvalidIssuerError, JWT::InvalidAudError
        # Invalid Token
        # puts "INVALID"
        return nil
      rescue JWT::JWKError, JWT::DecodeError
        # Invalid
        # puts "JWK ERROR"
        return nil
      rescue
        # Etc
        return nil
      end
    end

    def jwks
      cache.fetch('json_web_keys', **cache_options) do
        uri = URI("https://#{Rails.application.credentials.auth[:domain]}/.well-known/jwks.json")
        response = Net::HTTP.get(uri)
        JWT::JWK::Set.new(JSON.parse(response))
      end
    end

    def jwks_hash
      cache.fetch('json_web_keys_hash', **cache_options) do
        jwks.keys.map { |k| [key.kid, key.public_key] }.to_h
      end
    end

    private

    def cache
      Rails.cache
    end

    def fetch_cached_token(token)
      cache.read(token, namespace: CACHE_NAMESPACE)
    end

    def write_cached_token(token, payload)
      cache.write(
        token,
        payload,
        expires_in: payload[:expires_in].seconds,
        race_condition_ttl: 10.seconds,
        namespace: CACHE_NAMESPACE,
      )
    end

    def jwk_loader
      ->(options) do
        @cached_keys = nil if options[:invalidate]
        @cached_keys ||= jwks
      end
    end

    def token_payload(decoded_token)
      payload = decoded_token.first.merge(decoded_token.last.slice("kid")).symbolize_keys
      payload[:user_id] = payload[:sub].gsub(/auth0\|/, '')
      payload.delete(:sub)
      payload[:expires_in] = (payload[:exp] - payload[:iat]).to_i
      payload[:exp] = Time.at(payload[:exp])
      payload[:iat] = Time.at(payload[:iat])
      OpenStruct.new(payload)
    end

    def decoder_options
      {
        algorithms: 'RS256',
        iss: Rails.application.credentials.auth[:issuer],
        verify_iss: true,
        aud: Rails.application.credentials.auth[:audience],
        verify_aud: true,
        verify_iat: true,
        jwks: jwk_loader,
      }
    end

    def cache_options
      { expires_in: 24.hours, race_condition_ttl: 10.seconds, namespace: CACHE_NAMESPACE }
    end
  end
end
