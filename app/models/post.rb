class Post < ApplicationRecord
  belongs_to :user
  belongs_to :collection

  has_one_attached :image
  has_many :post_metadata, dependent: :destroy

  validates :title, presence: true, length: { in: 2..20 }
  validates :content, presence: true, length: { in: 2..50 }

  # class method ✨

  def self.create_usecase(user_id, collection_id, title, content, metadata_list, file)
    transaction do
      post = self.new(
        title: title,
        content: content,
        user_id: user_id,
        collection_id: collection_id,
      )
      post.image.attach(file)
      post.save!

      metadata_list.each do |metadata|
        PostMetadatum.create!(
          post_id: post.id,
          content: metadata["content"],
          is_public: metadata["isPublic"],
          has_link: metadata["hasLink"]
        )
      end

      post
    end
  end

  # instance method ✨

  def update_usecase(title, content, metadata_list)
    transaction do
      update!(title: title, content: content)

      # 기존 메타데이터 삭제 (한 번의 SQL 실행으로 처리)
      post_metadata.delete_all

      # 새로운 메타데이터 추가 (배열을 한 번에 삽입)
      post_metadata.create!(metadata_list.map { |metadata|
        { content: metadata["content"], is_public: metadata["isPublic"], has_link: metadata["hasLink"] }
      })
    end
  end


  def to_detail
    {
      id: id,
      title: title,
      content: content,
      collection_id: collection.id,
      collection: {
        id: collection.id,
        title: collection.title
      },
      category: collection.category ? {
        id: collection.category.id,
        name: collection.category.name,
        created_at: collection.category.created_at,
        updated_at: collection.category.updated_at
      } : nil,
      metadata_list: post_metadata.map { |meta| { content: meta.content, is_public: meta.is_public, has_link: meta.has_link } }
    }
  end
end
