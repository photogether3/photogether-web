class Admin::UsersController < Admin::AdminController
  def index
    page     = params[:page] ||= 1
    per_page = 10
    order    = params[:order] ||= "desc"
    order_by = params[:order_by] ||= "created_at"
    keyword  = params[:keyword] ||= ""
    @users = User.all
    @users = @users.where("email_address LIKE :q OR nickname LIKE :q", q: "%#{keyword}%") if keyword.present?
    @users = @users.page(page).per(per_page)
    @users = @users.order("#{order_by} #{order}")

    respond_to do |format|
      format.turbo_stream { render "query" }
      format.html
    end
  end

  def new
    @user = User.new
    respond_to do |format|
      format.turbo_stream { render "new" }
      format.html
    end
  end

  def create
    email_address         = params[:email_address] ||= ""
    password              = params[:password] ||= ""
    password_confirmation = password

    @user = User.new
    @user.email_address = email_address
    @user.password = password
    @user.password_confirmation = password_confirmation
    @user.role_id = 1
    @user.nickname = BaseUtil.generate_random_nickname
    @user.is_email_verified = true

    @user.save

    respond_to do |format|
      format.turbo_stream
    end
  end
end
