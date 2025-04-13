module PostConcern
  private

  def find_post(post_id, user_id)
    post = Post.find_by(id: post_id, user_id: user_id)
    return Result.failure("게시물을 찾을 수 없습니다.") unless post
    Result.success(post)
  end

  # Post Id 목록으로 Post 모델을 반환합니다.
  def get_post_group(post_ids = [])
    posts = Post.where(id: post_ids)
    return Result.failure("게시물 그룹을 찾을 수 없습니다.") if posts.empty?
    Result.success(posts)
  end
end
