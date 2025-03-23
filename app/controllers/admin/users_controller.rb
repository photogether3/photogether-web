class Admin::UsersController < Admin::AdminController
  def index
    @users = User.order(created_at: :desc)
    @user = User.new
  end

  def new
    @user = User.new

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("dialog", partial: "admin/users/form", locals: { user: @user })
        ]
      end
    end
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
            turbo_stream.prepend("user_list", partial: "admin/users/user_part", locals: { user: @user })
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
