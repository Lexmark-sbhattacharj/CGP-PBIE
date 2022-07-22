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
    announcements = Announcement.all
    for x in announcements
      if x.scope == "Global"
        announcement=x
      end
    end
    return announcement.present? && (Time.now.strftime('%m-%d-%Y  %H:%M:%S')) >= (announcement.start_date.strftime('%m-%d-%Y  %H:%M:%S')) && (Time.now.strftime('%m-%d-%Y  %H:%M:%S')) <= (announcement.end_date.strftime('%m-%d-%Y  %H:%M:%S')) && (announcement.scope=="Global")
  end

  def show_maintenance_page
    announcements = Announcement.all
    announcements.each do |x|
      next unless x.scope != 'Global'

      workspace = Workspace.find_by(name: x.scope)
      if (Time.now.strftime('%m-%d-%Y  %H:%M:%S')) >= (x.start_date.strftime('%m-%d-%Y  %H:%M:%S')) && (Time.now.strftime('%m-%d-%Y  %H:%M:%S')) <= (x.end_date.strftime('%m-%d-%Y  %H:%M:%S'))
        workspace.maintain = true
      else
        workspace.maintain = false
      end
      workspace.save
    end

    redirect_to '/maintenance' if isMaintenance? && request.fullpath != '/maintenance'
  end
end
