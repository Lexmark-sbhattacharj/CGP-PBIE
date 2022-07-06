# frozen_string_literal: true

# user model
class User < ApplicationRecord
  has_many :user_workspaces
  has_many :workspaces, through: :user_workspaces
  has_many :usage_metrics

  include PublicActivity::Model
  tracked

  def all_activities
    all_activities = {}
    usage_metrics.each do |activity|
      all_activities[activity.date_on.strftime('%Y-%m-%d')] ||= []
      all_activities[activity.date_on.strftime('%Y-%m-%d')] << activity
    end
    all_activities
  end

  def record_usage_activity(params)
    args = {
      workspace_id: params['workspace_id'], dataset_id: params['dataset_id'],
      report_name: params['report_name'], workspace_name: params['workspace_name'],
      idempotence_key: params['idempotence_key']
    }
    UsageMetric.today(self).record_activity(params['report_id'], args)

    self.last_viewed_report = params['report_name']
    self.last_viewed_workspace = params['idempotence_key']
    save
  end

  def maybe_update_name_and_uid(name, uid)
    return if uid.nil? || name.nil?

    self.onboarded = true
    self.name = name
    self.uid = uid
    save
  end

  def self.from_omniauth(auth_hash)
    email, uid, name = AuthHelper.pluck_user_data(auth_hash)

    user = User.where(email: email.downcase).first_or_create
    user.uid = uid
    user.name = name
    user.onboarded = true
    user.save!
    user
  end

  def workspaces
    if is_admin?
      Workspace.all
    else
      super
    end
  end
end
