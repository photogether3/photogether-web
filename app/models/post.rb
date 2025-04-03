class Post < ApplicationRecord
  include PostApiPresentable

  # 관계 설정
  belongs_to :user
  belongs_to :collection
  has_many :post_metadata, dependent: :destroy
  has_one_attached :image do |attachable|
    attachable.variant :blur, resize_to_limit: [ 30, nil ]
    attachable.variant :grid, resize_to_limit: [ 360, nil ]
    attachable.variant :detail, resize_to_limit: [ 750, nil ]
  end

  # 유효성 검증
  validates :title, length: { maximum: 50 }, allow_blank: true
  validates :content, length: { maximum: 50 }, allow_blank: true

  def self.create_with_metadata(user_id, collection_id, title, content, metadata_list, file)
    transaction do
      # 제목이 없고 메타데이터가 있는 경우 메타데이터에서 제목 추출
      if title.blank?
        title = PostMetadatum.extract_title_from_metadata(metadata_list)
      end

      post = self.new(
        title: title.presence || "제목 없음",
        content: content.presence || "내용 없음",
        user_id: user_id,
        collection_id: collection_id,
      )

      post.image.attach(file) if file.present?
      post.save!

      PostMetadatum.create_from_array!(post, metadata_list)

      # 트랜잭션 내에서 비동기 작업 예약
      if post.image.attached?
        ProcessImageVariantsJob.perform_later(post.id)
      end

      post
    end
  end

  def update_with_metadata(title, content, metadata_list)
    transaction do
      # 제목이 없고 메타데이터가 있는 경우 메타데이터에서 제목 추출
      if title.blank?
        title = PostMetadatum.extract_title_from_metadata(metadata_list)
      end

      update!(
        title: title.presence,
        content: content.presence || ""
      )

      # 기존 메타데이터 삭제
      post_metadata.delete_all

      # 새로운 메타데이터 추가
      PostMetadatum.create_from_array!(self, metadata_list)

      self
    end
  end
end
