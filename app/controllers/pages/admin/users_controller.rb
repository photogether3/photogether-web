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
    post_total = user.posts.length

    render Pages::Admin::Users::Show.new(
      user: user_result,
      favorite_categories: user_favorite_categories,
      post_total: post_total
    )
  end
end
