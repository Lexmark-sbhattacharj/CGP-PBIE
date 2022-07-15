# frozen_string_literal: true

# methods for managing user creation, usage tracking and access to workspaces
class UsersController < ApplicationController
  before_action :show_maintenance_page
  def index
    return render json: { status: :not_authorized } unless @current_user.is_admin?

    render json: User.all
  end

  def show
    return render json: { status: :not_authorized } unless @current_user.is_admin?

    user_id = params[:id]
    @user = User.find(user_id)
    response = {
      user: @user,
      activities: @user.all_activities,
      workspaces: @user.workspaces.sort_by(&:name)
    }
    response[:usage_metrics] = @user.usage_metrics.order('date_on desc').limit(3) if @current_user.is_admin?
    render json: response
  end

  def update
    return render json: { status: :not_authorized } unless @current_user.is_admin?

    @user = User.find(params[:id])
    @user.roles = params[:user][:roles]
    @user.email = params[:user][:email]
    @user.save
    render json: { status: :updated }
  end

  def create
    workspace = Workspace.find(params[:workspace_id])
    user = User.find_or_create_by(email: params[:user][:email].downcase)
    UserWorkspace.find_or_create_by(workspace_id: workspace.id, user_id: user.id)
    @current_user.create_activity(:added_user, params: { user_id: user.id })
    ACIMService.create_user(user.email)
    render json: { status: :created, user: user.as_json(except: :is_admin) }
  end

  def destroy
    if params[:workspace_id]
      workspace = Workspace.find(params[:workspace_id])
      user = User.find(params[:id])
      UserWorkspace.where(workspace_id: workspace.id, user_id: user.id).first.delete
      render json: { status: :deleted }
    else
      # this is a request to delete the user
      user = User.find(params[:id])
      if user.is_admin?
        render json: { error: :delete_lock }
      else
        UserWorkspace.where(user_id: user.id).delete_all
        user.delete
        render json: { status: :deleted }
      end
    end
  end

  def last_viewed
    render json: {
      last_viewed_report: @current_user.last_viewed_report,
      last_viewed_workspace: @current_user.last_viewed_workspace
    }
  end
end
