unless Rails.env.test?
  module Auth0
    module Mixins
      module HTTPProxy
        # Overload this method in the Auth0 ruby gem in order to
        # inject the VGS Proxy configuration
        # @see https://github.com/auth0/ruby-auth0/blob/cc794c0c76ab84b9cd659aa4bd0dd5c3e452b02f/lib/auth0/mixins/httpproxy.rb#L108
        def call(method, url, timeout, headers, body = nil)
          RestClient::Request.execute(
            method: method,
            url: url,
            timeout: timeout,
            headers: headers,
            payload: body,

            # Add our VGS Proxy options
            proxy: ::VGS.outbound_proxy,
            ssl_cert_store: ::VGS.cert_store,
          )
        rescue RestClient::Exception => e
          case e
          when RestClient::RequestTimeout
            raise Auth0::RequestTimeout.new(e.message)
          else
            return e.response
          end
        end
      end
    end
  end
end

module AuthZero
  class Client
    include Singleton

    attr_accessor :client

    def initialize
      @client = Auth0Client.new(AuthZero::Params.for_client)
    end
  end

  class Params
    def self.for_client
      Rails.application.credentials.auth.slice(
        :client_id,
        :client_secret,
        :management_domain,
        :domain,
      ).merge({
        api_version: 2,
        timeout: 10,
      })
    end

    def self.for_create_user(user)
      {
        user_id: user.id,
        email: user.email,
        email_verified: false,
        # phone_number: user.phone_number,
        # phone_verified: false,
        blocked: false,
        name: user.full_name,
        given_name: user.first_name,
        family_name: user.last_name,
        connection: AuthZero.connection,
        password: user.password,
        verify_email: true,
      }
    end

    def self.for_patch_user(user)
      {
        # user_id: user.id,
        email: user.email,
        # email_verified: false,
        # phone_number: user.phone_number,
        # phone_verified: false,
        # blocked: false,
        name: user.full_name,
        given_name: user.first_name,
        family_name: user.last_name,
        connection: AuthZero.connection,
        # password: user.password,
        # verify_email: true,
      }
    end
  end

  def self.client
    AuthZero::Client.instance.client
  end

  def self.connection
    Rails.application.credentials.auth[:connection]
  end
end
