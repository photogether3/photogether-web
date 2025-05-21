class Post::Index
  include PaginationConcern
  include CollectionConcern

  def initialize(user_id, params = {})
    @user_id = user_id
    @collection_id = params[:collectionId]
    @page = params[:page] || 1
    @per_page = params[:perPage] || 10
    @sort_order = params[:sortOrder] || "desc"
    @sort_by = params[:sortBy] || "created_at"

    # 정렬 방향 유효성 검사 추가
    @sort_order = "desc" unless [ "asc", "desc" ].include?(@sort_order.to_s.downcase)

    # 정렬 필드 유효성 검사 추가
    valid_sort_fields = [ "created_at", "updated_at", "title" ]
    @sort_by = "created_at" unless valid_sort_fields.include?(@sort_by.to_s.downcase)
  end

  def call
    collection_result = find_collection(@collection_id, @user_id)
    return collection_result if collection_result.failure?
    collection = collection_result.data

    posts = Post
      .where(user_id: @user_id, collection_id: collection.id)
      .order(@sort_by => @sort_order)
      .includes(:collection, :post_metadata)
      .page(@page).per(@per_page)

    response_data = paginated_response_for(posts) do |post|
      post.to_detail
    end

    Result.success(response_data)
  end
end
