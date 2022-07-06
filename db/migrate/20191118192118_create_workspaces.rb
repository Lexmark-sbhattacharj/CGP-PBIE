class CreateWorkspaces < ActiveRecord::Migration[5.2]
  def change
    create_table :workspaces, id: :uuid  do |t|
      t.string :name
      t.uuid :pbi_workspace_id
      t.timestamps
    end
  end
end
