class CreatePowerbiTokens < ActiveRecord::Migration[5.2]
  def change
    create_table :powerbi_tokens, id: :uuid do |t|
      t.text :access_token
      t.datetime :expires

      t.timestamps
    end
  end
end
