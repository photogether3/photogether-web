class Api::ApplicationApiController < ActionController::API
  # 모든 응답 후 camelCase 변환을 적용
  after_action :camelize_response_keys

  # 모든 API 요청에서 토큰 정보 로깅 (토큰이 있는 경우만)
  before_action :log_token_info

  # 모든 예외를 한 메서드에서 처리
  rescue_from StandardError, with: :handle_api_error

  protected
    # 토큰 정보 로깅 메서드 - 모든 API 요청에서 실행됨
    def log_token_info
      auth_header = request.headers["Authorization"]
      return unless auth_header.present?

      token = extract_token(auth_header)
      return unless token.present?

      payload = decode_token(token)
      return unless payload.present?

      # 페이로드 정보 로깅
      user_id = payload["sub"]
      Rails.logger.info("Request with token - User ID: #{user_id}, Token Exp: #{Time.at(payload['exp']).iso8601 rescue 'N/A'}")

      # 사용자 정보가 있다면 추가 로깅 (선택적)
      if user = find_user_by_id(user_id)
        Rails.logger.info("Request User: #{user.email_address} (#{user.nickname || 'no nickname'})")

        # 현재 사용자 정보 저장 (인증 여부와 무관하게)
        @current_user_info = user
      end
    end

    # 사용자 인증 메서드 - 인증이 필요한 API에서만 호출
    def authenticate_user!
      auth_header = request.headers["Authorization"]

      unless auth_header.present?
        return unauthorized_error("UNAUTHORIZED_001", "토큰이 유효하지 않습니다.")
      end

      token = extract_token(auth_header)
      unless token.present?
        return unauthorized_error("UNAUTHORIZED_002", "토큰이 유효하지 않습니다.")
      end

      payload = decode_token(token)
      unless payload.present?
        return unauthorized_error("UNAUTHORIZED_003", "토큰이 유효하지 않습니다.")
      end

      user = find_user_by_id(payload["sub"])
      unless user.present?
        return unauthorized_error("UNAUTHORIZED_004", "사용자를 찾을 수 없습니다.")
      end

      # 인증된 현재 사용자 저장
      @current_user = user
      Rails.logger.info("Authenticated User ID: #{@current_user.id}")
    end

    # 현재 사용자 반환 (인증 메서드를 통과한 경우만 유효)
    def current_user
      @current_user
    end

    # 현재 사용자 정보 반환 (인증 여부와 무관하게 토큰이 있었다면 제공)
    def current_user_info
      @current_user_info
    end

    # ------------------------------------------------
    # 성공, 실패에 대한 랜더링 처리
    # ------------------------------------------------
    def render_result(result, success_status: :ok, failure_status: :bad_request)
      if result.success?
        render json: result.data || { message: "성공" }, status: success_status
      else
        render json: {
          errorCode: 400,
          code: result.error_code, # 에러 코드가 있으면 사용, 없으면 기본값
          message: result.error_message
        }, status: failure_status
      end
    end

  private
    # 인증 토큰 추출 헬퍼
    def extract_token(auth_header)
      auth_header.split("Bearer ").last if auth_header.present?
    end

    # 토큰 디코딩 헬퍼
    def decode_token(token)
      Auth::TokenManager.decode_token(token)
    rescue => e
      Rails.logger.warn("Token decode error: #{e.message}")
      nil
    end

    # 사용자 조회 헬퍼
    def find_user_by_id(user_id)
      User.find_by(id: user_id.to_i) if user_id.present?
    rescue => e
      Rails.logger.warn("User lookup error: #{e.message}")
      nil
    end

    # 인증 오류 응답 헬퍼
    def unauthorized_error(code, message)
      Rails.logger.warn("Authentication failed: #{code}")
      render json: {
        errorCode: 401,
        code: code,
        message: message
      }, status: :unauthorized and return
    end

    # JSON 응답의 모든 키를 camelCase로 변환
    def camelize_response_keys
      return unless response.content_type&.include?("application/json")
      return if response.body.blank?

      begin
        json = JSON.parse(response.body)
        camelized_json = if json.is_a?(Array)
          json.map { |obj| obj.deep_transform_keys { |key| key.to_s.camelize(:lower) } }
        else
          json.deep_transform_keys { |key| key.to_s.camelize(:lower) }
        end
        response.body = camelized_json.to_json
      rescue JSON::ParserError => e
        Rails.logger.error("JSON 파싱 에러: #{e.message}")
      end
    end

    # API 예외 처리
    def handle_api_error(exception)
      # 공통 기본 로깅
      Rails.logger.error "Caught exception: #{exception.class}"
      Rails.logger.error(exception.message)

      # 모든 환경에서 상세 에러 로그 기록
      Rails.logger.error("===== API Error Details =====")
      Rails.logger.error("Exception class: #{exception.class}")
      Rails.logger.error("Message: #{exception.message}")
      Rails.logger.error("Controller: #{controller_name}##{action_name}")
      Rails.logger.error("Backtrace (first 3 lines):")
      exception.backtrace.first(3).each do |line|
        Rails.logger.error("  #{line}")
      end

      case exception
      when ActiveRecord::RecordInvalid
        # 유효성 검증 실패 상세 로깅
        record = exception.record
        full_messages = record&.errors&.full_messages || []

        Rails.logger.error("===== Validation Error Details =====")
        Rails.logger.error("Model: #{record.class.name}")
        Rails.logger.error("Attributes: #{record.attributes.inspect}")
        Rails.logger.error("Errors by field:")
        record.errors.messages.each do |field, msgs|
          Rails.logger.error("  #{field}: #{msgs.join(', ')}")
        end

        message = record&.errors&.full_messages&.first || exception.message
        render json: {
          errorCode: 400,
          code: "VALIDATION_ERROR",
          message: message
        }, status: 400

      when ActiveRecord::RecordNotFound
        # 레코드를 찾을 수 없음 상세 로깅
        model = exception.model
        id = exception.id

        Rails.logger.error("===== Record Not Found Details =====")
        Rails.logger.error("Model: #{model}")
        Rails.logger.error("ID: #{id}")
        Rails.logger.error("Primary Key: #{exception.primary_key}")

        render json: {
          errorCode: 400,
          code: "NOTFOUND_ERROR",
          message: exception.message
        }, status: 400

      when ArgumentError
        # 인자 에러 상세 로깅
        Rails.logger.error("===== Argument Error Details =====")
        Rails.logger.error("Params: #{params.to_unsafe_h}")
        Rails.logger.error("Request body: #{request.raw_post}") if request.raw_post.present?

        render json: {
          errorCode: 400,
          code: "ARGUMENT_ERROR",
          message: exception.message
        }, status: 400

      when CustomError
        # CustomError 상세 로깅
        error_code = exception.respond_to?(:error_code) ? exception.error_code : "C_BAD_REQUEST"

        Rails.logger.error("===== Custom Error Details =====")
        Rails.logger.error("Error Code: #{error_code}")
        Rails.logger.error("Message: #{exception.message}")
        Rails.logger.error("Details: #{exception.details}") if exception.respond_to?(:details)

        render json: {
          errorCode: 400,
          code: error_code,
          message: exception.message
        }, status: 400

      else
        # 예상치 못한 서버 오류 상세 로깅
        Rails.logger.error("===== Server Error Details =====")
        Rails.logger.error("Exception: #{exception.class}")
        Rails.logger.error("Message: #{exception.message}")
        Rails.logger.error("Backtrace (first 10 lines):")
        exception.backtrace.first(10).each_with_index do |line, i|
          Rails.logger.error("  #{i+1}. #{line}")
        end

        render json: {
          errorCode: 500,
          code: "INTERNAL_SERVER_ERROR",
          message: "무언가 잘못됐어요."
        }, status: 500
      end
    end
end
