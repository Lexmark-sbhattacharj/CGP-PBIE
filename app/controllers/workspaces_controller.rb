# frozen_string_literal: true

# methods for managing workspaces associated to powerbi workspaces
class WorkspacesController < ApplicationController
  before_action :show_maintenance_page
  before_action :set_workspace, only: %i[reports show update destroy]

  def index
    render json: @current_user.workspaces
  end

  def show
    render json: {
      id: @workspace.id,
      name: @workspace.name,
      users: @workspace.users
    }
  end

  def create
    @workspace = Workspace.create(params[:workspace].permit(:name, :pbi_workspace_id))
    if @workspace.valid?
      @workspace.users << @current_user unless @current_user.is_admin?
      render json: @workspace
    else
      render json: {
        errors: @workspace.errors,
        status: 422
      }
    end
  end

  def update
    @workspace.name = params[:workspace][:name]
    @workspace.pbi_workspace_id = params[:workspace][:pbi_workspace_id]
    @workspace.save
    render json: @workspace
  end

  def destroy
    @workspace.delete
    render json: { status: :deleted }
  end

  def reports
    reports = @workspace.reports
    reports['value']&.reject! { |report| report['name'] == 'Report Usage Metrics Report' }
    @reports = reports
    render json: @reports
  end

  private

  def set_workspace
    @workspace = @current_user.workspaces.find { |w| w.id == params['id'] }
  end
end
