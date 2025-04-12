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
    User::UpdateProfile.new(@current_user, params).call
    render json: @current_user.to_detail, status: :ok
  end

  def update_password_by_otp
    result = User::UpdateOtpPassword.new(params).call
    return render_result(result) if result.failure?

    render json: { message: "성공" }, status: :ok
  end

  def update_password
    result = User::UpdateCurrentPassword.new(@current_user, params).call
    return render_result(result) if result.failure?

    render json: @current_user.to_detail, status: :ok
  end

  def reset_data
    result = User::ResetData.new(@current_user, params).call
    render_result(result, success_status: :ok)
  end

  def destroy
    result = User::Withdraw.new(@current_user, params).call
    render_result(result, success_status: :ok)
  end
end
