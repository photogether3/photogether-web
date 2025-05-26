class Pages::Admin::Users::PostsController < Pages::AdminController
  def show
    user_id = params[:user_id]
    post_id = params[:post_id]
    post = Post.where(user_id: user_id, id: post_id).first

    if post.nil?
      flash[:alert] = "게시물을 찾을 수 없습니다."
      redirect_to "/admin/users/#{user_id}", status: :see_other
    end

    render Pages::Admin::Users::Posts::Show.new(post: post)
  end
end
