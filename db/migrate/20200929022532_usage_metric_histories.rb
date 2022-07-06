class UsageMetricHistories < ActiveRecord::Migration[5.2]
  def change
    create_table :usage_metric_histories do |t|
      t.date :date_on
      t.string :report_id
      t.string :report_name
      t.string :workspace_id
      t.string :workspace_name
      t.string :idempotence_key
      t.integer :view_count
      t.uuid :user_id
      t.timestamps
    end

    add_index :usage_metric_histories, [:report_id, :report_name, :user_id, :date_on], name: :usage_metric_histories_idx
  end
end