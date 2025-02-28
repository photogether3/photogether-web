class Api::ApplicationApiController < ActionController::API
  # 모든 응답 후 camelCase 변환을 적용
  after_action :camelize_response_keys

  # 모든 예외를 한 메서드에서 처리
  rescue_from StandardError, with: :handle_api_error

  protected

  def ensure_valid_email
    email = params[:email]
    raise ArgumentError unless email.match?(User::VALID_EMAIL_REGEX)
  end

  def ensure_valid_password
    password = params[:password]
    raise ArgumentError, "Password missing" if password.blank?
    raise ArgumentError, "That's a weird password" if password.length <= 4 || password.length >= 30
  end

  def authenticate_user!
    auth_header = request.headers["Authorization"]
    unless auth_header.present?
      render json: {
        errorCode: 401,
        code: "UNAUTHORIZED_001",
        message: "토큰이 유효하지 않습니다."
      }, status: :unauthorized and return
    end

    token = auth_header.split("Bearer ").last
    unless token.present?
      render json: {
        errorCode: 401,
        code: "UNAUTHORIZED_002",
        message: "토큰이 유효하지 않습니다."
      }, status: :unauthorized and return
    end

    payload = JwtUtil.decode_token(token)
    if payload.nil?
      render json: {
        errorCode: 401,
        code: "UNAUTHORIZED_003",
        message: "토큰이 유효하지 않습니다."
      }, status: :unauthorized and return
    end

    puts "payload: #{payload}"

    user = User.find_by(id: payload["sub"].to_i)
    if user.nil?
      render json: {
        errorCode: 401,
        code: "UNAUTHORIZED_004",
        message: "사용자를 찾을 수 없습니다."
      }, status: :unauthorized and return
    end

    @current_user = user
  end

  private

  # JSON 응답의 모든 키를 camelCase로 변환
  def camelize_response_keys
    return unless response.content_type&.include?("application/json")
    return if response.body.blank?

    begin
      # 응답 본문을 JSON 객체로 변환
      json = JSON.parse(response.body)
      # 모든 키를 camelCase로 변환
      camelized_json = json.deep_transform_keys { |key| key.to_s.camelize(:lower) }
      Rails.logger.info "camelized_json: #{camelized_json}"

      response.body = camelized_json.to_json
    rescue JSON::ParserError => e
      Rails.logger.error("JSON 파싱 에러: #{e.message}")
    end
  end

  # API 예외 처리
  def handle_api_error(exception)
    Rails.logger.error "Caught exception: #{exception.class}"
    Rails.logger.error(exception.message)

    case exception
    when ActiveRecord::RecordInvalid
      # RecordInvalid(주로 유효성 검증 실패)
      record  = exception.record
      message = record&.errors&.full_messages&.join(", ") || exception.message

      render json: {
        errorCode: 400,
        code: "VALIDATION_ERROR",
        message: message
      }, status: 400

    when ActiveRecord::RecordNotFound
      # RecordNotFound(레코드를 찾을 수 없음)
      render json: {
        errorCode: 400,
        code: "NOTFOUND_ERROR",
        message: exception.message
      }, status: 400

    when ArgumentError
      # ArgumentError(잘못된 인자, 파라미터 에러 등)
      render json: {
        errorCode: 400,
        code: "ARGUMENT_ERROR",
        message: exception.message
      }, status: 400

    when CustomError
      # CustomError 처리 (예외 객체에 error_code가 있다고 가정)
      render json: {
        errorCode: 400,
        code: "C_BAD_REQUEST",
        message: exception.message
      }, status: 400

    else
      # 그 외 모든 예외(범용 처리)
      render json: {
        errorCode: 500,
        code: "INTERNAL_SERVER_ERROR",
        message: "무언가 잘못됐어요."
      }, status: 500
    end
  end
end
