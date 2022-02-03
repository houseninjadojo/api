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

class Auth::CreateUserJob < ApplicationJob
  queue_as :critical

  # https://auth0.com/docs/api/management/v2#!/Users/post_users
  def perform(user_id)
    user = User.find(user_id)
    options = options_for_user(user)

    auth_client.create_user(auth_connection, options)
    user.update!(auth_zero_user_created: true)
  end

  private

  def options_for_user(user)
    {
      user_id: user.id,
      email: user.email,
      email_verified: false,
      # phone_number: user.phone_number,
      # phone_verified: false,
      blocked: false,
      name: user.name,
      connection: auth_connection,
      password: user.password,
      verify_email: true,
    }
  end

  def auth_client
    options = Rails.application.credentials.auth.slice(
      :client_id,
      :client_secret,
      :management_domain,
    ).merge({
      api_version: 2,
      timeout: 10,
    })
    options[:domain] = options[:management_domain]
    @client ||= Auth0Client.new(**options)
  end

  def auth_connection
    Rails.application.credentials.auth[:connection]
  end
end
