class Post < ApplicationRecord
  belongs_to :user
  belongs_to :collection

  has_one_attached :image
  has_many :post_metadatum, dependent: :destroy

  validates :title, presence: true, length: { in: 2..20 }
  validates :content, presence: true, length: { in: 2..50 }

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
          is_public: metadata["isPublic"]
        )
      end

      post
    end
  end
end
