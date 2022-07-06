# frozen_string_literal: true

require 'uri'
require 'cgi'

# methods for managing user sessions and redirecting to auth service
class SessionsController < ApplicationController
  skip_before_action :require_sign_in
  skip_before_action :verify_authenticity_token

  add_flash_types :info, :error, :warning

  def login
    render layout: false
  end

  def mps
    url = [
      "#{ENV.fetch('IDP_URL', nil)}#{ENV.fetch('IDP_AUTHORITY_URL', nil)}?client_id=#{ENV.fetch('IDP_CLIENT_ID', nil)}",
      "redirect_uri=#{ENV.fetch('IDP_REDIRECT_URI', nil)}",
      'federation_redirect=true',
      'organization=',
      'response_type=token'
    ].join('&')
    redirect_to url
  end

  def user_exists_in_idp?(email)
    token = IDPService.access_token

    RestClient.get("#{ENV.fetch('IDP_URL', nil)}/rest/users/find_first_by_email?email=#{email}",
                   { 'Authorization' => "Bearer #{token}" }) do |response, _request, _result|
      response.code == 200
    end
  end

  def mps_authorize
    session['access_token'] = params['access_token']
    email, uid, name = IDPService.get_user_from_token(params['access_token'])
    user = User.find_or_create_by(email: email.downcase)
    user.maybe_update_name_and_uid(name, uid)

    session['user_id'] = user.id
    redirect_to '/'
  end

  def mps_callback
    render layout: false
  end

  def new
    redirect_to '/auth/azureactivedirectory'
  end

  def redirect
    render layout: false
  end

  def route
    username = params['username'].strip.split[0]
    if username =~ URI::MailTo::EMAIL_REGEXP
      session['user_name'] = username
      if username.ends_with?('lexmark.com')
        redirect_to '/auth/azure_oauth2'
      elsif user_exists_in_idp?(username)
        redirect_to '/mps/'
      else
        redirect_to '/auth/azureactivedirectory'
      end
    else
      redirect_to '/auth/login', notice: 'Please enter a valid email address'
    end
  end

  def create
    user = User.from_omniauth(auth_hash)
    session['user_id'] = user.id
    redirect_to '/'
  end

  def destroy
    user = User.find_by_id(session['user_id'])
    user = User.find_by_uid(session['user_id']) if user.nil?
    username = user.email
    reset_session
    if username.ends_with?('lexmark.com')
      redirect_to 'https://login.microsoftonline.com/logout.srf'
    elsif user_exists_in_idp?(username)
      redirect_to "#{ENV.fetch('IDP_URL', nil)}/auth/users/logout"
    else
      resp = RestClient.get(ENV.fetch('B2C_OPENID_CONFIG_URL', nil))
      body = JSON.parse(resp.body)
      redirect_to "#{body['end_session_endpoint']}&post_logout_redirect_uri=#{CGI.escape(ENV.fetch('REPORTING_URL',
                                                                                                   nil))}"
    end
  end

  def reset_password
    redirect_url = "#{CGI.escape(ENV.fetch('REPORTING_URL', nil))}/auth/azureactivedirectory/callback"
    reset_password_url = ENV['B2C_RESET_PASSWORD_URL'].gsub('https%3A%2F%2Fjwt.ms', redirect_url)
    puts reset_password_url
    redirect_to reset_password_url
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end
