class Api::V1::UserApiController < Api::ApplicationApiController
  before_action :authenticate_user!, except: [ :is_email_taken, :update_password_by_otp ]

  def is_email_taken
    email = params[:email]

    unless email.match?(User::VALID_EMAIL_REGEX)
      return render json: { is_duplicated: false }, status: :ok
    end

    user = User.find_by(email_address: email)
    render json: { is_duplicated: !user.nil? }, status: :ok
  end

  def show
    render_user_json(@current_user)
  end

  def update
    nickname = params[:nickname]
    bio      = params[:bio]
    file     = params[:file]

    @current_user.nickname = nickname if nickname.present?
    @current_user.bio      = bio if bio.present?

    # 기존 이미지 교체 또는 새로 첨부
    if file.present?
      @current_user.image.purge if @current_user.image.attached?
      @current_user.image.attach(file)
    end

    @current_user.save!

    render_user_json(@current_user)
  end

  def update_password_by_otp
    user = User.find_by(email_address: params[:email])
    raise ActiveRecord::RecordNotFound, "사용자를 찾을 수 없습니다." unless user

    is_valid = user.verify_otp!(params[:otp])
    raise CustomError, "OTP has expired" unless is_valid

    user.update!(
      password: params[:password],
      password_confirmation: params[:password],
      otp: nil,
      otp_expiry_date: nil,
    )

    render_user_json(user)
  end

  def update_password
    current_password = params[:currentPassword]
    new_password     = params[:newPassword]

    raise CustomError, "기존의 비밀번호가 일치하지 않습니다." if !@current_user.authenticate(current_password)

    @current_user.update(password: new_password, password_confirmation: new_password)
    render_user_json(@current_user)
  end

  def reset_data
    otp = params[:otp]
    is_valid = @current_user.verify_otp(otp)
    raise CustomError, "OTP has expired" unless is_valid

    @current_user.reset_data_usecase
    render json: { message: "데이터가 초기화되었습니다." }, status: :ok
  end

  def destroy
    otp = params[:otp]
    is_valid = @current_user.verify_otp(otp)
    raise CustomError, "OTP has expired" unless is_valid

    @current_user.destroy
    render json: { message: "계정이 삭제되었습니다." }, status: :ok
  end

  private

  # 사용자 정보를 JSON으로 렌더링합니다.
  def render_user_json(user)
    image_url = user.image.attached? ? url_for(user.image) : nil
    render json: user.as_json.merge(image_url: image_url), status: :ok
  end
end
