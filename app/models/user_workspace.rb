# frozen_string_literal: true

# model for association user to workspaces
class UserWorkspace < ActiveRecord::Base
  belongs_to :user
  belongs_to :workspace
end
