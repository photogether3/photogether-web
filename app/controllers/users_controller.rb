class UsersController < ApplicationController
  allow_unauthenticated_access

  def new
    @user = User.new
  end

  def create
    puts user_params
    nickname = User.generate_random_nickname
    otp = User.generate_otp
    otp_expiry_date = 5.minutes.from_now
    is_email_verified = false
    role_id = 1

    user_params_with_defaults = user_params.merge(
      nickname: nickname,
      otp: otp,
      otp_expiry_date: otp_expiry_date,
      is_email_verified: is_email_verified,
      role_id: role_id
    )

    @user = User.new(user_params_with_defaults)

    if @user.save
      redirect_to user_otp_path(@user.id), notice: "회원가입이 완료되었습니다. 이메일 인증을 진행해주세요."
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

  def otp
    @user = User.find(params[:id])
  end

  def verify_otp
    @user = User.find(params[:id])
    if @user.otp == params[:otp]
      @user.update(is_email_verified: true)
      redirect_to root_path, notice: "이메일 인증이 완료되었습니다."
    else
      redirect_to user_otp_path(@user), alert: "OTP 번호가 일치하지 않습니다."
    end
  end

  private

  def user_params
    params.require(:user).permit(:email_address, :password, :password_confirmation)
  end
end
