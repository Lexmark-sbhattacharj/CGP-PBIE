class CreateUsageMetrics < ActiveRecord::Migration[5.2]
  def change
    create_table :usage_metrics do |t|
      t.date :date_on
      t.json :report_views
      t.uuid :user_id
      t.timestamps
    end
  end
end
