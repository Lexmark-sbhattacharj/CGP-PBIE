module OmniAuth
  module Strategies
    class AzureActiveDirectory
      include OmniAuth::AzureActiveDirectory
      include OmniAuth::Strategy

      class OAuthError < StandardError; end

      def raw_authorize_endpoint_url 
        ENV['B2C_RAW_AUTHORIZE_ENDPOINT_URL']
      end
      def openid_config_url
        ENV['B2C_OPENID_CONFIG_URL']
      end
      def signing_keys_url
        ENV['B2C_SIGNING_KEYS_URL']
      end
      def fetch_signing_keys
        response = JSON.parse(Net::HTTP.get(URI(signing_keys_url)))
        response['keys']
      rescue JSON::ParserError
        raise StandardError, 'Unable to fetch AzureAD signing keys.'
      end
      def base64_to_long(data)
        decoded_with_padding = Base64.urlsafe_decode64(data) + Base64.decode64('==')
        decoded_with_padding.to_s.unpack('C*').map do |byte|
          to_hex(byte)
        end.join.to_i(16)
      end
 
      def to_hex(int)
        int < 16 ? '0' + int.to_s(16) : int.to_s(16)
      end

      def read_nonce
        session.delete('omniauth-azure-activedirectory.nonce')
      end

      def new_nonce
        session['omniauth-azure-activedirectory.nonce'] = SecureRandom.uuid
      end

      def validate_and_parse_id_token(id_token)
        if id_token.nil? 
          return Rack::Response.new(['302 Moved'], 302, 'Location' => "/").finish
          #raise Exception.new('Missing id token')
        end
        
        jwt_claims, jwt_header =
          JWT.decode(id_token, nil, true, verify_options) do |header|
            signing_key = (signing_keys.find do |key|
              key['kid'] == header['kid']
            end || {})
            if signing_key.nil? || signing_key.empty?
              fail JWT::VerificationError,
                   'No keys from key endpoint match the id token'
            end
            exponent = signing_key['e']
            modulus = signing_key['n']
       
            key = OpenSSL::PKey::RSA.new
            key.set_key(base64_to_long(modulus), base64_to_long(exponent), nil)
           
            key.public_key
          end   
        return jwt_claims, jwt_header
      end

      def authorize_endpoint_url
        uri = URI(raw_authorize_endpoint_url)
        uri.query = URI.encode_www_form(client_id: client_id,
                                        redirect_uri: callback_url,
                                        response_mode: response_mode,
                                        response_type: response_type,
                                        nonce: new_nonce,
                                        p: 'B2C_1A_SignIn_v2',
                                        scope: 'openid',
                                        login_hint: session['user_name'])
        uri.to_s
      end
      def verify_options
        { verify_expiration: true,
          verify_not_before: true,
          verify_iat: true,
          verify_aud: true,
          leeway: 30,
          'aud' => client_id }
      end
    end
  end
end