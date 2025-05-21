# db/migrate/YYYYMMDDHHMMSS_change_post_metadata_content_limit.rb
class ChangePostMetadataContentLimit < ActiveRecord::Migration[8.0]
  def up
    # content 컬럼의 제한을 50에서 100으로 변경
    change_column :post_metadata, :content, :string, limit: 100, null: false
  end

  def down
    # 롤백 시 원래 상태로 복원
    change_column :post_metadata, :content, :string, limit: 50, null: false
  end
end
