class CreatePostMetadata < ActiveRecord::Migration[8.0]
  def change
    create_table :post_metadata do |t|
      t.integer :post_id, null: false
      t.integer :rank, null: false, default: 1
      t.string :content, limit: 50, null: false
      t.boolean :is_public, null: false, default: true

      t.timestamps
    end

    add_foreign_key :post_metadata, :posts, column: :post_id, on_delete: :cascade
  end
end
