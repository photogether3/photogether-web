class Pages::Admin::UsersController < Pages::AdminController
  def index
    render Users::Index.new
  end
end
