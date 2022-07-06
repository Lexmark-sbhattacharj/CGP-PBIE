# frozen_string_literal: true

# methods for auth processing
class AuthHelper
  def self.pluck_user_data(auth_hash)
    if auth_hash['provider'] == 'azure_oauth2'
      email = auth_hash['info']['email']
      uid = auth_hash['uid']
      name = auth_hash['info']['name']
    else
      email = auth_hash[:extra][:raw_info][:id_token_claims][:emails].first
      uid = auth_hash[:uid]
      name = auth_hash[:info][:name]
    end
    [email, uid, name]
  end
end
