class CreateAnnouncements < ActiveRecord::Migration[5.2]
  def change
    create_table :announcements do |t|
      t.string :title
      t.datetime :start_date
      t.datetime :end_date
      t.string :scope
      t.timestamps
    end
  end
end
