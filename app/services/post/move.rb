class Post::Move
  include PostConcern
  include CollectionConcern

  def initialize(user_id, post_ids = [], collection_id)
    @post_ids = post_ids
    @collection_id = collection_id
    @user_id = user_id
  end

  def call
    collection_result = find_collection(@collection_id, @user_id)
    return collection_result if collection_result.failure?
    collection = collection_result.data

    posts_result = get_post_group(@post_ids)
    return posts_result if posts_result.failure?
    posts = posts_result.data

    posts.update_all(collection_id: collection.id)

    Result.success
  end
end
