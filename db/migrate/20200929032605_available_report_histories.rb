class AvailableReportHistories < ActiveRecord::Migration[5.2]
  def change
    create_table :available_report_histories do |t|
      t.date :date_on
      t.string :report_id
      t.string :report_name
      t.string :pbi_workspace_id
      t.string :idempotence_key
      t.timestamps
    end

    add_index :available_report_histories, [:date_on, :report_id, :pbi_workspace_id], name: :available_report_history_idx
    add_index :available_report_histories, [:idempotence_key], name: :available_report_history_by_id_idx
  end
end
