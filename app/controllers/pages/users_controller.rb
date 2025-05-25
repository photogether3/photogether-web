class Pages::UsersController < Pages::SessionController
  def show
    render Pages::User::Index.new(current_user: current_user)
  end
end
