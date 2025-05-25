class Pages::UsersController < Pages::SessionController
  layout -> { Layouts::Application.new(
    layout: Pages::Layout.new(
      nav_component: Pages::Users::Sidebar.new
    )
  ) }

  def show
    user_result = current_user.to_detail
    user_favorite_categories = current_user.favorite_categories
    user_posts = current_user.posts.order(created_at: :desc).map(&:to_detail)

    render Pages::Users::Show.new(
      user: user_result,
      favorite_categories: user_favorite_categories,
      posts: user_posts
    )
  end
end
