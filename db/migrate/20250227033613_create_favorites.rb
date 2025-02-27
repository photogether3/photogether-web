class CreateFavorites < ActiveRecord::Migration[8.0]
  def change
    create_table :favorites do |t|
      t.integer :category_id, null: false
      t.integer :user_id, null: false

      t.timestamps
    end

    add_foreign_key :favorites, :categories, column: :category_id
    add_foreign_key :favorites, :users, column: :user_id
  end
end
