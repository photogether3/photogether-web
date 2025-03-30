class Admin::UsersController < Admin::AdminController
  def index
    page     = params[:page] ||= 1
    per_page = 5
    order    = params[:order] ||= "desc"
    order_by = params[:order_by] ||= "created_at"
    keyword  = params[:keyword] ||= ""

    @users = User.all
    @users = @users.where("email_address LIKE :q OR nickname LIKE :q", q: "%#{keyword}%") if keyword.present?
    @users = @users.page(page).per(per_page)
    @users = @users.order("#{order_by} #{order}")

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("user_list", partial: "admin/users/user_list")
      end
      format.html
    end
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    user_params = params.require(:user).permit(:email_address, :password, :nickname)
    nickname = user_params[:nickname].presence || BaseUtil.generate_random_nickname

    user_attributes = user_params.merge(
      password_confirmation: user_params[:password],
      role_id: 1,
      is_email_verified: true,
      nickname: nickname
    )

    respond_to do |format|
      begin
        @user = User.create_with_default_collections(user_attributes)
        format.turbo_stream { head :ok }
      rescue ActiveRecord::RecordInvalid, StandardError => e
        @user = User.new(user_attributes)
        @user.errors.add(:base, e.message) if @user.errors.empty?
        @modal_anims = ""
        format.html { render :new, status: :unprocessable_entity }
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
        format.turbo_stream { head :ok }
      else
        @modal_anims = ""
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.turbo_stream do
        @users = User.all
        render turbo_stream: [
          turbo_stream.remove("user_#{@user.id}"),
          turbo_stream.replace("user_total", partial: "shared/item_total", locals: {
            total_count_id: "user_total",
            total_count: User.all.count,
            content: "총 회원 수"
          })
        ]
      end
    end
  end
end
