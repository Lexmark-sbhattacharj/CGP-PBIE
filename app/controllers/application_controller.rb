# frozen_string_literal: true

# base application controller
class ApplicationController < ActionController::Base
  before_action :require_sign_in
  protect_from_forgery with: :exception, prepend: true

  def require_sign_in
    redirect_to '/auth/login' if current_user.nil?
  end

  def current_user
    @current_user ||= User.find_by_id(session['user_id'])
  end
end
