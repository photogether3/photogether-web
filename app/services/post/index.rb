class Post::Index
  include PaginationConcern
  include CollectionConcern

  def initialize(user_id, collection_id)
    @user_id = user_id
    @collection_id = collection_id
  end

  def call
    collection_result = find_collection(@collection_id, @user_id)
    return collection_result if collection_result.failure?
    collection = collection_result.data

    pagination = pagination_params

    posts = Post
      .where(user_id: @user_id, collection_id: collection.id)
      .order(pagination[:sort_by] => pagination[:sort_order])
      .includes(:collection, :post_metadata)
      .page(pagination[:page]).per(pagination[:per_page])

    response_data = paginated_response_for(posts) do |post|
      post.to_detail
    end

    success(response_data)
  end
end
