Rails.application.config.middleware.use OmniAuth::Builder do
  provider :azure_activedirectory, ENV['AD_CLIENT_ID'], ENV['AD_CLIENT_SECRET']

  provider :azure_oauth2, client_id: ENV['AZURE_CLIENT_ID'], 
           client_secret: ENV['AZURE_CLIENT_SECRET'], tenant_id: ENV['AZURE_TENANT_ID']
end