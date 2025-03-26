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
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace('user_list', partial: "admin/users/user_list")
      end
      format.html
    end
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @anims = "motion-preset-focus"
    @user = User.new
  end

  def create
    user_params = params.require(:user).permit(:email_address, :password, :nickname)
    nickname = user_params[:nickname].presence || BaseUtil.generate_random_nickname

    @user = User.new(user_params.merge(
      password_confirmation: user_params[:password],
      role_id: 1,
      is_email_verified: true,
      nickname: nickname
    ))

    respond_to do |format|
      if @user.save
        format.html { redirect_to admin_users_url, notice: "사용자가 성공적으로 생성되었습니다." }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end


  def edit
    @user = User.find(params[:id])
  end

  def update
    user_params = params.require(:user).permit(:email_address, :password, :nickname)
    nickname = user_params[:nickname].presence || BaseUtil.generate_random_nickname

    @user = User.find(params[:id])
    @user.assign_attributes(user_params.except(:password))
    @user.nickname = nickname

    if user_params[:password].present?
      @user.password = user_params[:password]
      @user.password_confirmation = user_params[:password]
    end

    respond_to do |format|
      if @user.save
        format.html { redirect_to admin_users_url, notice: "사용자가 성공적으로 수정되었습니다." }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove("user_#{@user.id}") }
      format.html { redirect_to admin_users_path, notice: "사용자가 삭제되었습니다." }
    end
  end

end
