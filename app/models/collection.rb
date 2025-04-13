# app/models/collection.rb
class Collection < ApplicationRecord
  include Rails.application.routes.url_helpers

  # STI(Single Table Inheritance)를 비활성화하기 위해 사용됩니다.
  self.inheritance_column = nil

  # ------------------------------------------------------
  # 관계 설정
  # ------------------------------------------------------
  belongs_to :user
  belongs_to :category, optional: true
  has_many :posts, dependent: :destroy

  # ------------------------------------------------------
  # 유효성 검사 (사진첩 제목)
  # ------------------------------------------------------
  validates :title, presence: true, length: { in: 2..50 }

  # ------------------------------------------------------
  # 스코프 설정
  # ------------------------------------------------------
  scope :with_posts_count, -> {
    select("collections.*, (SELECT COUNT(*) FROM posts WHERE posts.collection_id = collections.id) AS posts_count")
  }

  def is_system_collection?
    # 시스템 관리 사진첩인지 확인하는 메서드 (삭제 불가능)
    # TRASH 또는 UNCATEGORIZED인 경우 true
    self.type == "TRASH" || self.type == "UNCATEGORIZED"
  end

  # ------------------------------------------------------
  # 상세 반환타입
  # ------------------------------------------------------
  def to_detail
    {
      id: id,
      title: title,
      type: type,
      category: category ? { id: category.id, name: category.name } : nil,
      post_count: attributes["posts_count"].to_i,
      image_urls: get_image_urls,
      created_at: created_at.iso8601(3),
      updated_at: updated_at.iso8601(3)
    }
  end

  private

  # 최근 이미지 3개의 URL 가져오기
  def get_image_urls
    # 최근 이미지 3개 가져오기 (게시물 ID 내림차순)
    # ActiveStorage 관계를 사용하여 이미지가 있는 게시물만 필터링
    recent_posts_with_images = posts
      .joins("INNER JOIN active_storage_attachments ON active_storage_attachments.record_id = posts.id AND active_storage_attachments.record_type = 'Post' AND active_storage_attachments.name = 'image'")
      .distinct
      .order(id: :desc)
      .limit(3)

    # 각 이미지의 원본 및 변형 URL 생성
    recent_posts_with_images.map do |post|
      # joins로 이미 필터링되었기 때문에 attached? 체크는 불필요하지만, 안전을 위해 유지
      next unless post.image.attached?

      variants = post.image_variants

      {
        id: post.id,
        blur: variants[:blur] ? url_for(variants[:blur]) : nil,
        grid: variants[:grid] ? url_for(variants[:grid]) : nil,
        detail: variants[:detail] ? url_for(variants[:detail]) : nil
      }
    end.compact
  end
end
