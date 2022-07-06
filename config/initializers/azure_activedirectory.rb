require 'jwt'
require 'omniauth'
require 'openssl'
require 'securerandom'

module OmniAuth
  module Strategies
    # A strategy for authentication against Azure Active Directory.
    class AzureActiveDirectory
      include OmniAuth::AzureActiveDirectory
      include OmniAuth::Strategy

      class OAuthError < StandardError; end

      # Overridden method from OmniAuth::Strategy. This is the second step in
      # the authentication process. It is called after the user enters
      # credentials at the authorization endpoint.
      def callback_phase
        error = request.params['error_reason'] || request.params['error']
        if error && error == "access_denied"
          return Rack::Response.new(['302 Moved'], 302, 'Location' => "/reset_password").finish
        elsif error
          fail(OAuthError, error)
        end 

        @session_state = request.params['session_state']
        @id_token = request.params['id_token']
        @code = request.params['code']
        @claims, @header = validate_and_parse_id_token(@id_token)
        validate_chash(@code, @claims, @header)
        super
      end


      def validate_chash(code, claims, header)
        # response from b2c is not sending id_token and code, so validate_chash is optional
        # setting to true by default
        # https://openid.net/specs/openid-connect-core-1_0.html#HybridIDToken
        # 3.3.2.11.  ID Token
        true
      end
    end
  end
end