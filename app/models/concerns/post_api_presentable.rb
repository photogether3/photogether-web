# app/models/concerns/post_api_presentation.rb
module PostApiPresentable
  extend ActiveSupport::Concern

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
      metadata_list: post_metadata.map(&:to_hash)
    }
  end

  def image_variants
    return { blur: nil, grid: nil, detail: nil } unless image.attached?

    {
      blur: image.variant(:blur),
      grid: image.variant(:grid),
      detail: image.variant(:detail)
    }
  end
end
