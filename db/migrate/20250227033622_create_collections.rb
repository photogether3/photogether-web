class CreateCollections < ActiveRecord::Migration[8.0]
  def change
    create_table :collections do |t|
      t.integer :user_id, null: false
      t.integer :category_id
      t.string :type, limit: 20, null: false, default: 'default'
      t.string :title, limit: 50, null: false

      t.timestamps
    end

    add_foreign_key :collections, :users, column: :user_id, on_delete: :cascade
    add_foreign_key :collections, :categories, column: :category_id
  end
end
