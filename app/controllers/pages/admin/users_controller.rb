class Pages::Admin::UsersController < Pages::AdminController
  def index
    users = User.order(created_at: :desc)
    user_results = users.map(&:to_detail)
    render Users::Index.new(users: user_results)
  end

  def show
    user = User.find(params[:id])
    user_result = user.to_detail
    render Users::Show.new(user: user_result)
  end
end
