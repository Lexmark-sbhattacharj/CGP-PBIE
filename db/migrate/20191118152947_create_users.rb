class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users, id: :uuid do |t|
      t.string :email, null: false, default: ""
      t.string :uid
      t.string :name
      t.string :roles
      t.boolean :is_admin, default: false
      t.boolean :onboarded, default: false
      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, :uid, unique: true
  end
end
