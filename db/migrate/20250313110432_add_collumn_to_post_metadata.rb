class AddCollumnToPostMetadata < ActiveRecord::Migration[8.0]
  def change
    change_table :post_metadata do |t|
      t.boolean :has_link, null: false, default: false
    end
  end
end
