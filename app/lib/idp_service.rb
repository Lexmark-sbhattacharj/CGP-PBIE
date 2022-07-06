# frozen_string_literal: true

# methods for managing b2c tokens
class IDPService
  def self.get_user_from_token(access_token)
    resp = RestClient.get("#{ENV.fetch('IDP_URL', nil)}/oauth/token/info",
                          { 'Authorization' => "Bearer #{access_token}" })
    record = JSON.parse(resp.body)
    [record['resource_owner']['email'], record['resource_owner']['uid'], record['resource_owner']['display_name']]
  end

  def self.access_token
    resp = RestClient.post("#{ENV.fetch('IDP_URL', nil)}#{ENV.fetch('IDP_OAUTH2_TOKEN_URL', nil)}", { client_id: ENV.fetch('IDP_CLIENT_ID', nil),
                                                                                                      client_secret: ENV.fetch(
                                                                                                        'IDP_CLIENT_SECRET', nil
                                                                                                      ),
                                                                                                      grant_type: 'client_credentials' })
    record = JSON.parse(resp.body)
    record['access_token']
  end
end
