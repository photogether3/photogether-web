class Pages::Admin::UsersController < Pages::AdminController
  def index
    users = User.order(created_at: :desc)
    user_results = users.map(&:to_detail)
    render Pages::Admin::Users::Index.new(users: user_results)
  end

  def show
    user = User.find(params[:id])
    user_result = user.to_detail

    user_favorite_categories = user.favorite_categories
    user_posts = user.posts.order(created_at: :desc).map(&:to_detail)

    render Pages::Admin::Users::Show.new(
      user: user_result,
      favorite_categories: user_favorite_categories,
      posts: user_posts
    )
  end
end
