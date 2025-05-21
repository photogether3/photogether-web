class Pages::Admin::UserController < Pages::AdminController
  def index
    render User::Index.new
  end
end
