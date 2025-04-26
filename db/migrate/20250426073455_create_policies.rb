class CreatePolicies < ActiveRecord::Migration[8.0]
  def change
    create_table :policies do |t|
      t.string :title, null: false
      t.string :kind, null: false  # 'terms', 'privacy', 'marketing' 등
      t.text :content, null: false
      t.string :version, null: false
      t.boolean :is_active, default: true
      t.datetime :effective_date, null: false

      t.timestamps
    end

    add_index :policies, [ :kind, :version ], unique: true
  end
end
