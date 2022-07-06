# frozen_string_literal: true

# methods for managing powerbi api
class PowerBIService
  def self.get_reports_by_workspace(workspace_id)
    get("https://api.powerbi.com/v1.0/myorg/groups/#{workspace_id}/reports")
  end

  def self.get_workspace(workspace_id)
    get("https://api.powerbi.com/v1.0/myorg/groups?$filter=id+eq+'#{workspace_id}'")
  end

  def self.get_report_token(report_id, workspace_id, dataset_id, current_user)
    dataset_metadata = get("https://api.powerbi.com/v1.0/myorg/groups/#{workspace_id}/datasets/#{dataset_id}")
    body = build_request_body_for_report_token(dataset_id, dataset_metadata, current_user)
    url = "https://api.powerbi.com/v1.0/myorg/groups/#{workspace_id}/reports/#{report_id}/GenerateToken"
    post(url, body.to_json)
  end

  def self.refresh_token(report_id, workspace_id, dataset_id, current_user)
    PowerbiToken.instance.delete
    get_report_token(report_id, workspace_id, dataset_id, current_user)
  end

  def self.build_request_body_for_report_token(dataset_id, dataset_metadata, current_user)
    if dataset_metadata['isEffectiveIdentityRequired'] && dataset_metadata['isEffectiveIdentityRequired'] == true
      username = pluck_username(current_user)
      identity_request(username, dataset_id, current_user)
    else
      basic_request
    end
  end

  def self.identity_request(username, dataset_id, current_user)
    user_roles = current_user.roles ? current_user.roles.split(',') : []
    {
      accessLevel: 'view',
      identities: [
        {
          username: username,
          datasets: [dataset_id],
          roles: user_roles
        }
      ]
    }
  end

  def self.basic_request
    { accessLevel: 'view' }
  end

  def self.pluck_username(current_user)
    if current_user.email.include?('@lexmark.com')
      email = current_user.email.split('@')[0].strip
      "#{email}@LexmarkAD.onmicrosoft.com"
    else
      current_user.email
    end
  end

  def self.powerbi_token
    body = {
      client_id: ENV.fetch('PBI_CLIENT_ID', nil),
      grant_type: 'password',
      username: ENV.fetch('PBI_USERNAME', nil),
      password: ENV.fetch('PBI_PASSWORD', nil),
      scope: 'openid',
      resource: ENV.fetch('PBI_RESOURCE_URL', nil)
    }
    post_with_no_headers(ENV.fetch('PBI_OAUTH2_URL', nil), body)
  end

  def self.client
    @client ||= RestClient
  end

  def self.headers
    { Authorization: "Bearer #{pbi_access_token}", 'Content-Type': 'application/json' }
  end

  def self.pbi_access_token
    PowerbiToken.instance.pbi_access_token
  end

  def self.get(url)
    client.get(url, headers) do |response, _request, result|
      if result.code.to_i == 200
        JSON.parse(response.body)
      else
        { error: 'not_authorized' }
      end
    end
  end

  def self.post_with_no_headers(url, body)
    client.post(url, body) do |response, _request, _result|
      JSON.parse(response.body)
    end
  end

  def self.post(url, body)
    client.post(url, body, headers) do |response, _request, _result|
      JSON.parse(response.body)
    end
  end
end
