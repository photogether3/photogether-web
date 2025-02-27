class CreatePosts < ActiveRecord::Migration[8.0]
  def change
    create_table :posts do |t|
      t.integer :user_id, null: false
      t.integer :collection_id, null: false
      t.string :title, limit: 50, null: false
      t.string :content, limit: 100, null: false
      t.string :image_url, limit: 255

      t.timestamps
    end

    add_foreign_key :posts, :users, column: :user_id, on_delete: :cascade
    add_foreign_key :posts, :collections, column: :collection_id
  end
end
