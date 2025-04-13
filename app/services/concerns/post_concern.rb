module PostConcern
  private

  def find_post(post_id, user_id)
    post = Post.find_by(id: post_id, user_id: user_id)
    return Result.failure("게시물을 찾을 수 없습니다.") unless post
    Result.success(post)
  end
end
