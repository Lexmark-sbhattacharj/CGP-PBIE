class LastViewed < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :last_viewed_workspace, :string
    add_column :users, :last_viewed_report, :string
  end
end
