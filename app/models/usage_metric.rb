# frozen_string_literal: true

# model for usage tracking
class UsageMetric < ApplicationRecord
  def self.today(current_user)
    today = Time.now.strftime('%Y-%m-%d')
    UsageMetric.find_or_create_by(date_on: today, user_id: current_user.id)
  end

  def record_activity(report_id, params)
    self.report_views ||= {}
    maybe_seed_report_views(report_id, params)
    self.report_views[report_id]['count'] += 1
    self.report_views[report_id]['idempotence_key'] = params[:idempotence_key]
    save
    UsageMetricHistory.sync(user_id, date_on, report_id, self.report_views[report_id])
  end

  def maybe_seed_report_views(report_id, params)
    return if self.report_views.key? report_id

    self.report_views[report_id] = {
      report_name: params[:report_name],
      workspace_id: params[:workspace_id],
      workspace_name: params[:workspace_name],
      'count' => 0
    }
  end
end
