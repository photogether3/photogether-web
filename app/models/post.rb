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
  # id와 이미지만 조회
  # -------------------------------------------------------------
  def to_index_image
    {
      id: id,
      images: {
        blur: image.attached? ? Rails.application.routes.url_helpers.url_for(image.variant(:blur)) : nil,
        grid: image.attached? ? Rails.application.routes.url_helpers.url_for(image.variant(:grid)) : nil,
        detail: image.attached? ? Rails.application.routes.url_helpers.url_for(image.variant(:detail)) : nil
      }
    }
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

  # -------------------------------------------------------------
  # 이전/다음 포스트 조회 메서드
  # -------------------------------------------------------------
  def prev_post
    Post.where(collection_id: collection_id, user_id: user_id)
        .where("id < ?", id)
        .order(id: :desc)
        .first
  end

  def next_post
    Post.where(collection_id: collection_id, user_id: user_id)
        .where("id > ?", id)
        .order(id: :asc)
        .first
  end

  def prev_post_info
    post = prev_post
    return nil unless post

    prev_data = {
      id: post.id
    }

    # 이미지 URL 정보 추가
    if post.image.attached?
      variants = post.image_variants

      prev_data[:images] = {
        blur: variants[:blur] ? Rails.application.routes.url_helpers.url_for(variants[:blur]) : nil,
        grid: variants[:grid] ? Rails.application.routes.url_helpers.url_for(variants[:grid]) : nil,
        detail: variants[:detail] ? Rails.application.routes.url_helpers.url_for(variants[:detail]) : nil
      }
    else
      prev_data[:images] = { blur: nil, grid: nil, detail: nil }
    end

    prev_data
  end

  def next_post_info
    post = next_post
    return nil unless post

    next_data = {
      id: post.id
    }

    # 이미지 URL 정보 추가
    if post.image.attached?
      variants = post.image_variants

      next_data[:images] = {
        blur: variants[:blur] ? Rails.application.routes.url_helpers.url_for(variants[:blur]) : nil,
        grid: variants[:grid] ? Rails.application.routes.url_helpers.url_for(variants[:grid]) : nil,
        detail: variants[:detail] ? Rails.application.routes.url_helpers.url_for(variants[:detail]) : nil
      }
    else
      next_data[:images] = { blur: nil, grid: nil, detail: nil }
    end

    next_data
  end
end
