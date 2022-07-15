# frozen_string_literal: true

# method for managing pbi report token
class ReportsController < ApplicationController
  before_action :show_maintenance_page
  protect_from_forgery prepend: true, with: :exception

  def refresh_token
    report_id = params['report_id']
    workspace_id = params['workspace_id']
    dataset_id = params['dataset_id']
    @current_user.record_usage_activity(params)
    resp = PowerBIService.refresh_token(report_id, workspace_id, dataset_id, @current_user)
    render json: resp
  end

  def token
    report_id = params['report_id']
    workspace_id = params['workspace_id']
    dataset_id = params['dataset_id']
    @current_user.record_usage_activity(params)
    resp = PowerBIService.get_report_token(report_id, workspace_id, dataset_id, @current_user)
    render json: resp
  end
end
