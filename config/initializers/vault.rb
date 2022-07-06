require "base64"

def get_secrets(retries=0)
  logger = Rails.logger
  if retries < 10
    token = File.open('/var/run/secrets/kubernetes.io/serviceaccount/token').read

    url = "#{ENV['vault_addr']}/v1/auth/#{ENV['mount_point']}/login"
    headers = {'Content-Type': 'application/json'}
    params = {"jwt": token, "role": ENV['vault_role']}
    
    begin
      RestClient.post(url, params, headers){|response, request, result|
        token = JSON.parse(response.body)["auth"]["client_token"]

        Vault.address = ENV['vault_addr']
        Vault.token = token

        secrets = Vault.logical.read("secret/#{ENV['vault_application_secret']}")
        secrets.data.keys.each do |key|
          ENV[key.to_s.upcase.tr("-", "_")]=secrets.data[key]
        end
      }
    rescue Exception => err
      logger.error("Error getting secrets from vault -> #{err}")
      sleep(10)
      get_secrets(retries+1)
    end
  else
    logger.error("Max retries for vault reached")
  end
end

if File.exist?('/var/run/secrets/kubernetes.io/serviceaccount/token')
  get_secrets()  
end