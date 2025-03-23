class Admin::UsersController < Admin::AdminController
  def index
    page     = params[:page] ||= 1
    per_page = params[:per_page] ||= 5
    order    = params[:order] ||= "desc"
    order_by = params[:order_by] ||= "created_at"
    keyword  = params[:keyword] ||= ""

    @users = User.all
    @users = @users.where("email_address LIKE :q OR nickname LIKE :q", q: "%#{keyword}%") if keyword.present?
    @users = @users
      .order("#{order_by} #{order}")
      .page(page)
      .per(per_page)

    if turbo_frame_request?
      puts "turbo_frame_request"
      render partial: "admin/users/user_list", locals: { users: @users }
    else
      render :index
    end
  end

  def new
    @user = User.new
    render partial: "admin/users/new", locals: { user: @user }
  end

  def create
    user_params = params.permit(:email_address, :password, :password_confirmation, :nickname, :bio)
    @user = User.new(user_params)
    @user.role_id = 1
    @user.is_email_verified = true
    @user.nickname = BaseUtil.generate_random_nickname

    if @user.save
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.remove("dialog"),
            turbo_stream.action(:replace, "user_list", "<turbo-frame id='user_list' src='#{admin_users_path(request.query_parameters)}'></turbo-frame>")
          ]
        end
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("user_form", partial: "admin/users/form", locals: { user: @user })
          ]
        end
      end
    end
  end
end
