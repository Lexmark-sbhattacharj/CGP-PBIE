# frozen_string_literal: true

require 'cgi'

# methods for managing b2c tokens
class ACIMService
  @acim_create_user_url = [
    "#{ENV.fetch('ACIM_URL', nil)}/api/v1.0/adusers?clientId=#{ENV.fetch('ACIM_CLIENT_ID', nil)}",
    "redirectUri=#{ENV.fetch('REPORTING_URL', nil)}/auth/route",
    'responseMode=FormPost'
  ].join('&')

  def self.acim_token
    params = {
      'grant_type' => 'client_credentials',
      'scope' => ENV.fetch('B2C_OAUTH2_SCOPE', nil),
      'client_id' => ENV.fetch('B2C_CLIENT_ID', nil),
      'client_secret' => ENV.fetch('B2C_CLIENT_SECRET', nil)
    }
    resp = RestClient.post(ENV.fetch('B2C_OAUTH2_TOKEN_URL', nil), params)
    JSON.parse(resp.body)
  end

  def self.create_user(email_address)
    token = acim_token['access_token']
    create_user_in_acim(email_address, token)
  end

  def self.create_user_in_acim(email_address, token)
    resp = RestClient.post @acim_create_user_url,
                           { email: email_address, displayName: email_address }.to_json,
                           { Authorization: "Bearer #{token}", content_type: :json }
    puts "create_user_in_acim for email address: #{email_address}"
    puts @acim_create_user_url
    puts resp
    { status: :created }
  rescue RestClient::ExceptionWithResponse => e
    JSON.parse(e.http_body)
  end
end
