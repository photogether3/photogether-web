class Pages::Admin::UsersController < Pages::AdminController
  def index
    users = User.order(created_at: :desc)
    user_results = users.map(&:to_detail)
    render Users::Index.new(users: user_results)
  end
end
