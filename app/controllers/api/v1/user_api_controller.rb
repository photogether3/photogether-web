class Api::V1::UserApiController < Api::ApplicationApiController
  before_action :authenticate_user!, except: [ :is_email_taken, :update_password_by_otp ]

  def is_email_taken
    email = params[:email]

    # 이메일 형식이 유효하지 않은 경우는 조회까지 하지 않고 false 리턴
    # 입력시 계속해서 호출하는 경우가 있어 성능상 이점을 고려
    unless email.match?(ValidationPatterns::EMAIL_REGEX)
      return render json: { is_duplicated: false }, status: :ok
    end

    is_duplicated = User.exists?(email_address: email)
    render json: { is_duplicated: is_duplicated }, status: :ok
  end

  def show
    render json: @current_user.to_detail, status: :ok
  end

  def update
    User::ProfileUpdater.new(@current_user, params).call
    render json: @current_user.to_detail, status: :ok
  end

  def update_password_by_otp
    result = User::PasswordUpdater.new(@current_user, params).call
    render_user_json(user)
  end

  def update_password
    current_password = params[:currentPassword]
    new_password     = params[:newPassword]

    err_msg = "비밀번호를 입력해 주세요."
    raise CustomError, err_msg if current_password.blank?
    raise CustomError, err_msg if new_password.blank?

    if !@current_user.authenticate(current_password)
      raise CustomError, "기존의 비밀번호가 일치하지 않습니다."
    end

    @current_user.update!(password: new_password, password_confirmation: new_password)

    render_user_json(@current_user)
  end

  def reset_data
    otp = params[:otp]
    raise CustomError, "OTP는 6자리 숫자여야 합니다." unless otp.to_s.match?(User::VALID_OTP_REGEX)

    is_valid = @current_user.verify_otp(otp)
    raise CustomError, "OTP가 유효하지 않습니다." unless is_valid

    ActiveRecord::Base.transaction do
      u = @current_user
      # OTP 초기화
      u.update!(otp: nil, otp_expiry_date: nil)
      # 게시물 삭제
      u.posts.destroy_all if u.posts.exists?
      # 즐겨찾기 삭제
      u.favorites.destroy_all if u.favorites.exists?
      # 즐겨찾기 카테고리 삭제
      u.favorite_categories.destroy_all if u.favorite_categories.exists?
      # 일반 사진첩 삭제
      u.collections.where(type: "DEFAULT").destroy_all
    end
    render json: { message: "데이터가 초기화되었습니다." }, status: :ok
  end

  def destroy
    otp = params[:otp]
    raise CustomError, "OTP는 6자리 숫자여야 합니다." unless otp.to_s.match?(User::VALID_OTP_REGEX)

    is_valid = @current_user.verify_otp(otp)
    raise CustomError, "OTP가 유효하지 않습니다." unless is_valid

    @current_user.destroy
    render json: { message: "계정이 삭제되었습니다." }, status: :ok
  end
end
