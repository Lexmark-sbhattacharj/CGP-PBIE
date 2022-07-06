# frozen_string_literal: true

# model for historical usage tracking
class UsageMetricHistory < ActiveRecord::Base
  def self.sync(user_id, date_on, report_id, report_views)
    umh = usage_metric_history_for(report_views['report_name'],
                                   report_id, user_id, date_on)
    umh.view_count = report_views['count'].to_i
    umh.workspace_id = report_views['workspace_id']
    umh.workspace_name = report_views['workspace_name']
    umh.idempotence_key = report_views['idempotence_key']
    umh.save
  end

  def self.usage_metric_history_for(report_name, report_id, user_id, date_on)
    UsageMetricHistory.find_or_create_by(
      report_name: report_name,
      report_id: report_id,
      user_id: user_id,
      date_on: date_on
    )
  end
end
