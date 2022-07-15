# frozen_string_literal: true

# base application controller
class OperationsController < ApplicationController
  before_action :show_maintenance_page
  def check
    raise ActionController::RoutingError, 'Not Found' unless @current_user.email.ends_with?('lexmark.com')

    if params['env']
      render json: { val: "#{ENV.fetch(params['env'], nil)[0]}-#{ENV.fetch(params['env'], nil)[-2]}" }
    else
      render json: { status: 'unknown' }
    end
  end

  def version
    raise ActionController::RoutingError, 'Not Found' unless @current_user.email.ends_with?('lexmark.com')

    render json: { version: '0.147' }
  end
end
