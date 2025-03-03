class UsersController < ApplicationController
  allow_unauthenticated_access

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to root_path, notice: "회원가입이 완료되었습니다."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def check_email
    # 3초대기
    sleep 3
    email = params[:email]
    @user_exists = User.exists?(email_address: email)

    respond_to do |format|
      format.turbo_stream
    end
  end

  private

  def user_params
    params.require(:user).permit(:email_address, :password, :password_confirmation)
  end
end
