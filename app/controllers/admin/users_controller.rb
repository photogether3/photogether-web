class Admin::UsersController < Admin::AdminController
  def index
    @users = User.all
  end

  def new
    @user = User.new
  end
end
