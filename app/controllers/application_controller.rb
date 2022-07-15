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

  def isMaintenance?
    announcement=Announcement.last
    return announcement.present? && (Time.now.strftime('%Y-%m-%d  %I:%M:%S')) >= (announcement.start_date.strftime('%Y-%m-%d  %I:%M:%S')) && (Time.now.strftime('%Y-%m-%d  %I:%M:%S')) <= (announcement.end_date.strftime('%Y-%m-%d  %I:%M:%S')) && (announcement.scope=="Global")
  end

  def show_maintenance_page
    if isMaintenance?
      redirect_to '/maintenance' unless request.fullpath == '/maintenance'
    end
  end
end
