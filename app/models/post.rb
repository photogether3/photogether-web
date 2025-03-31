class Post < ApplicationRecord
  belongs_to :user
  belongs_to :collection

  has_one_attached :image
  has_many :post_metadata, dependent: :destroy

  # 타이틀과 컨텐츠를 필수가 아니게 변경하고 최대 길이를 50자로 수정
  validates :title, length: { maximum: 50 }, allow_blank: true
  validates :content, length: { maximum: 50 }, allow_blank: true

  # class method ✨

  # 게시물 제목이 없으면 메타데이터 첫번째 값 넣기 로직 추가
  def self.create_usecase(user_id, collection_id, title, content, metadata_list, file)
    transaction do
      # 제목이 없고 메타데이터가 있는 경우 첫번째 메타데이터의 content를 제목으로 사용
      if title.blank? && metadata_list.present? && metadata_list.first["content"].present?
        title = metadata_list.first["content"].truncate(50) # 50자 제한
      end

      # 내용이 없고 제목이 있는 경우, 제목을 내용으로 사용 (선택적)
      if content.blank? && title.present?
        content = title
      end

      post = self.new(
        title: title.presence || "제목 없음", # 제목이 여전히 없으면 기본값 설정
        content: content.presence || "내용 없음", # 내용이 여전히 없으면 기본값 설정
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
      # 제목이 없고 메타데이터가 있는 경우 첫번째 메타데이터의 content를 제목으로 사용
      if title.blank? && metadata_list.present? && metadata_list.first["content"].present?
        title = metadata_list.first["content"].truncate(50) # 50자 제한
      end

      update!(
        title: title.presence || "",
        content: content.presence || ""
      )

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
