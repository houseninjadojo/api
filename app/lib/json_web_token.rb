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

      begin
        decoded = JWT.decode(token, nil, true, **decoder_options) do |header|
          jwks_hash[header['kid']]
        end
        payload = token_payload(decoded)
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

      write_cached_token(token, payload)
      return payload
    end

    def jwks
      Rails.cache.fetch('jwt:json_web_keys', expires_in: 24.hours, race_condition_ttl: 10.seconds) do
        uri = URI("https://#{Rails.application.credentials.auth[:domain]}/.well-known/jwks.json")
        response = Net::HTTP.get(uri)
        JSON.parse(response)
      end
    end

    def jwks_hash
      Rails.cache.fetch('jwt:json_web_keys_hash', expires_in: 24.hours, race_condition_ttl: 10.seconds) do
        jwk_hash = Array(jwks['keys'])
        map = jwk_hash.map do |key|
          [
            key['kid'],
            OpenSSL::X509::Certificate.new(
              Base64.decode64(key['x5c'].first)
            ).public_key
          ]
        end
        Hash[map]
      end
    end

    private

    def fetch_cached_token(token)
      Rails.cache.read("jwt:#{token}")
    end

    def write_cached_token(token, payload)
      Rails.cache.write(
        "jwt:#{token}",
        payload,
        expires_in: payload[:expires_in].seconds,
        race_condition_ttl: 10.seconds,
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
  end
end
