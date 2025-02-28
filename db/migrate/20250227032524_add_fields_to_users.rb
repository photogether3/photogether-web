class AddFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    change_table :users do |t|
      t.integer :role_id, null: false
      t.string :nickname, limit: 20, null: false
      t.text :bio
      t.string :otp, limit: 6
      t.timestamp :otp_expiry_date
      t.boolean :is_email_verified, null: false, default: false
      t.string :image_url, limit: 255
    end

    add_foreign_key :users, :roles, column: :role_id
  end
end
