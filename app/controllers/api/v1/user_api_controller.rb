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
    user_data = user_with_image_url(@current_user)
    render json: user_data, status: :ok
  end

  def update
    nickname = params[:nickname]
    bio      = params[:bio]
    file     = params[:file]

    puts "file: #{file.inspect}"

    @current_user.nickname = nickname if nickname.present?
    @current_user.bio      = bio if bio.present?

    if params.key?(:file)
      case
      when file.nil?, file == "null"
        puts "파일 제거 요청으로 판단함"
        @current_user.image.purge if @current_user.image.attached?
      when file.respond_to?(:content_type)
        puts "파일 전달 됨!"
        @current_user.image.purge if @current_user.image.attached?
        @current_user.image.attach(file)
      else
        puts "file 형식이 유효하지 않음, 무시함"
      end
    end

    @current_user.save!

    user_data = user_with_image_url(@current_user)
    render json: user_data, status: :ok
  end

  def update_password_by_otp
    email    = params[:email]
    otp      = params[:otp]
    password = params[:password]

    raise CustomError, "유효한 이메일을 입력해 주세요." unless email.match?(User::VALID_EMAIL_REGEX)
    raise CustomError, "OTP는 6자리 숫자여야 합니다." unless otp.to_s.match?(User::VALID_OTP_REGEX)
    raise CustomError, "비밀번호를 입력해 주세요." if password.blank?

    user = User.find_by(email_address: email)
    raise ActiveRecord::RecordNotFound, "사용자를 찾을 수 없습니다." unless user

    is_valid = user.verify_otp(otp)
    raise CustomError, "OTP가 유효하지 않습니다." unless is_valid

    user.update!(
      password: password,
      password_confirmation: password,
      otp: nil,
      otp_expiry_date: nil,
    )

    user_data = user_with_image_url(user)
    render json: user_data, status: :ok
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

    @current_user.update!(
      password: new_password,
      password_confirmation: new_password
    )

    user_data = user_with_image_url(@current_user)
    render json: user_data, status: :ok
  end

  def reset_data
    otp = params[:otp]
    raise CustomError, "OTP는 6자리 숫자여야 합니다." unless otp.to_s.match?(User::VALID_OTP_REGEX)

    is_valid = @current_user.verify_otp(otp)
    raise CustomError, "OTP가 유효하지 않습니다." unless is_valid

    @current_user.reset_user_data!
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

  private

    # 사용자 데이터에 이미지 URL을 추가합니다
    def user_with_image_url(user)
      # 기본 사용자 정보 가져오기
      user_data = user.as_json

      # 이미지 URL 추가
      image_url = user.image.attached? ? url_for(user.image) : nil
      user_data.merge(image_url: image_url)
    end
end
