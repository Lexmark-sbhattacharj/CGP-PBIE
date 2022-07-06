class CreateUsersWorkspaces < ActiveRecord::Migration[5.2]
  def change
    create_table :user_workspaces, id: :uuid  do |t|
      t.uuid :user_id
      t.uuid :workspace_id
    end
  end
end
