# frozen_string_literal: true

# methods for admin
class AdminController < ApplicationController
  before_action :show_maintenance_page
  def index; end

  def people
    return render json: { status: :not_authorized } unless @current_user.is_admin?
  end

  def confirm_b2c_status
    return render json: { status: :not_authorized } unless @current_user.is_admin?

    resp = ACIMService.create_user(params['email'])

    if resp['error']&.include?('already exists')
      render json: { status: :exists }
    else
      render json: { status: :created, message: resp }
    end
  end
end
