# frozen_string_literal: true

# workspaces are associated to powerbi workspaces
class Workspace < ApplicationRecord
  has_many :user_workspaces
  has_many :users, through: :user_workspaces

  validates :name, presence: true

  def reports
    PowerBIService.get_reports_by_workspace pbi_workspace_id
  end

  def users
    super + User.where(is_admin: true)
  end
end
