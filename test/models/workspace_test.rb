# frozen_string_literal: true

require 'test_helper'

class WorkspaceTest < ActiveSupport::TestCase
  VCR.configure do |config|
    config.cassette_library_dir = 'fixtures/vcr_cassettes'
    config.hook_into :webmock
  end

  test 'not able to create a workspace with blank name' do
    workspace = Workspace.create(name: nil)
    refute workspace.valid?
  end

  test 'workspace has reports' do
    VCR.use_cassette('workspace_reports') do
      workspace = Workspace.find_by_pbi_workspace_id('5ee276ae-2485-4f3d-a453-db6d74869186')
      assert workspace.reports.count.positive?
    end
  end

  test 'workspace with no users can still be seen by admin users' do
    workspace = Workspace.find_by_pbi_workspace_id('5ee276ae-2485-4f3d-a453-db6d74869186')
    user_admin_status = workspace.users.map(&:is_admin)
    assert user_admin_status.uniq == [true]
  end
end
