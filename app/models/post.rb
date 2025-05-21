class Post < ApplicationRecord
  include Rails.application.routes.url_helpers
  
  # -------------------------------------------------------------
  # 관계 설정
  # -------------------------------------------------------------
  belongs_to :user
  belongs_to :collection
  has_one_attached :image do |attachable|
    attachable.variant :blur, resize_to_limit: [ 50, nil ]
    attachable.variant :grid, resize_to_limit: [ 360, nil ]
    attachable.variant :detail, resize_to_limit: [ 750, nil ]
  end
  has_many :post_metadata, dependent: :destroy

  # -------------------------------------------------------------
  # 유효성 검증
  # -------------------------------------------------------------
  validates :title, length: { maximum: 50 }, allow_blank: true
  validates :content, length: { maximum: 50 }, allow_blank: true

  # -------------------------------------------------------------
  # 상세 조회용 메서드
  # -------------------------------------------------------------
  def to_detail
    # 기본 데이터 구성
    post_data = {
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
      metadata_list: post_metadata.map(&:to_hash)
    }

    # 이미지 URL 추가
    if image.attached?
      variants = image_variants

      post_data.merge!(
        image_url: Rails.application.routes.url_helpers.url_for(image), # 원본 이미지 URL
        images: {
          blur: variants[:blur] ? Rails.application.routes.url_helpers.url_for(variants[:blur]) : nil,
          grid: variants[:grid] ? Rails.application.routes.url_helpers.url_for(variants[:grid]) : nil,
          detail: variants[:detail] ? Rails.application.routes.url_helpers.url_for(variants[:detail]) : nil
        }
      )
    else
      post_data.merge!(
        image_url: nil,
        images: { blur: nil, grid: nil, detail: nil }
      )
    end

    post_data
  end

  # -------------------------------------------------------------
  # 이미지 변형 메서드
  # -------------------------------------------------------------
  def image_variants
    return { blur: nil, grid: nil, detail: nil } unless image.attached?

    {
      blur: image.variant(:blur),
      grid: image.variant(:grid),
      detail: image.variant(:detail)
    }
  end
end
