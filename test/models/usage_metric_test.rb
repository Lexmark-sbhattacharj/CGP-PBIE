# frozen_string_literal: true

require 'test_helper'

class UsageMetricTest < ActiveSupport::TestCase
  test 'usage tracking' do
    user = User.first
    report_id = '12345'
    params = {
      workspace_id: '12345', dataset_id: '12345',
      report_name: 'report name', workspace_name: 'workspace name',
      idempotence_key: '12345'
    }
    UsageMetric.today(user).record_activity(report_id, params)

    assert UsageMetricHistory.find_by_user_id user.id
    assert UsageMetric.find_by_user_id user.id
  end
end
