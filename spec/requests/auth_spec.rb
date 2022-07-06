# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  config.before(:all, type: :request) do
    host! 'localhost:3000'
  end
end

RSpec.describe 'GET /' do
  it 'redirects to auth login' do
    get '/'
    expect(response.body).to include('auth/login')
  end

  it 'auth login asks for email' do
    get '/auth/login'
    expect(response.body).to include('Email Address')
  end

  it 'sends users that auth with IDP to IDP' do
    post '/auth/route', params: { username: 'testuser@customer.com' }
    expect(response.body).to include('/mps/')
  end

  it 'sends users that auth with B2C to BC2' do
    post '/auth/route', params: { username: 'creighton.medey@lexmark.es' }
    expect(response.body).to include('/auth/azureactivedirectory')
  end

  it 'sends users that have lexmark.com email addresses to azure oath2' do
    post '/auth/route', params: { username: 'creighton.medey@lexmark.com' }
    expect(response.body).to include('/auth/azure_oauth2')
  end

  it 'sends users linked from siebel portal to IDP' do
    get '/mps'
    expect(response.body).to include('idp')
    expect(response.body).to include('oauth/authorize?client_id=lxk')
  end
end
