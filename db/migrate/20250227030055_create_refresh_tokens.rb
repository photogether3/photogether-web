class CreateRefreshTokens < ActiveRecord::Migration[8.0]
  def change
    create_table :refresh_tokens do |t|
      t.integer :user_id, null: false
      t.string :refresh_token, null: false
      t.timestamp :expiry_date, null: false
      t.timestamp :last_refreshing_date, null: false

      t.timestamps
    end

    add_foreign_key :refresh_tokens, :users, column: :user_id, on_delete: :cascade
    add_index :refresh_tokens, :refresh_token, unique: true
  end
end
