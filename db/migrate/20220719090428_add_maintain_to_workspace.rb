class AddMaintainToWorkspace < ActiveRecord::Migration[5.2]
  def change
    add_column :workspaces, :maintain, :boolean, default: false
  end
end
