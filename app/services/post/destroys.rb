class Post::Destroys
  include PostConcern
  include CollectionConcern

  def initialize(user_id, post_ids = [])
    @user_id = user_id
    @post_ids = post_ids
  end

  def call
    posts_result = get_post_group
    return posts_result if posts_result.failure?
    posts = posts_result.data

    trash_collection = find_or_create_trash_for(@current_user)

    posts.update_all(collection_id: trash_collection.id)

    Result.success
  end
end
