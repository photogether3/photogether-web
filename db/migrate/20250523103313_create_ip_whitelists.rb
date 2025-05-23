class CreateIpWhitelists < ActiveRecord::Migration[8.0]
  def change
    create_table :ip_whitelists do |t|
      t.timestamps
      t.string :ip, limit: 50, null: false
      t.string :description, limit: 50, null: false
      t.boolean :is_active, default: true
    end
  end
end
