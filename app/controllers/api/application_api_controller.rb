class Api::ApplicationApiController < ActionController::API
  # 모든 응답 후 camelCase 변환을 적용
  after_action :camelize_response_keys

  # 모든 예외를 한 메서드에서 처리
  rescue_from StandardError, with: :handle_api_error

  protected

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

      # 현재 사용자를 인스턴스 변수에 저장
      @current_user = user
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
          code: "C_BAD_REQUEST",
          message: result.error_message
        }, status: failure_status
      end
    end

  private

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
      # 공통 기본 로깅 (유지)
      Rails.logger.error "Caught exception: #{exception.class}"
      Rails.logger.error(exception.message)

      # 테스트 환경에서는 더 자세한 정보 출력
      if Rails.env.test?
        puts "\n===== API Error Details =====\n"
        puts "Exception class: #{exception.class}"
        puts "Message: #{exception.message}"
        puts "Controller: #{controller_name}##{action_name}"
        puts "Backtrace (first 3 lines):"
        puts exception.backtrace.first(3).join("\n")
      end

      case exception
      when ActiveRecord::RecordInvalid
        # 유효성 검증 실패 상세 로깅
        record = exception.record
        full_messages = record&.errors&.full_messages || []

        Rails.logger.error("[VALIDATION_ERROR] Model: #{record.class.name}")
        Rails.logger.error("[VALIDATION_ERROR] Errors: #{full_messages.join(', ')}")

        if Rails.env.test?
          puts "\n===== Validation Error Details ====="
          puts "Model: #{record.class.name}"
          puts "Attributes: #{record.attributes.inspect}"
          puts "Errors by field:"
          record.errors.messages.each do |field, msgs|
            puts "  #{field}: #{msgs.join(', ')}"
          end
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

        Rails.logger.error("[NOTFOUND_ERROR] Model: #{model}, ID: #{id}")

        if Rails.env.test?
          puts "\n===== Record Not Found Details ====="
          puts "Model: #{model}"
          puts "ID: #{id}"
          puts "Primary Key: #{exception.primary_key}"
        end

        render json: {
          errorCode: 400,
          code: "NOTFOUND_ERROR",
          message: exception.message
        }, status: 400

      when ArgumentError
        # 인자 에러 상세 로깅
        Rails.logger.error("[ARGUMENT_ERROR] #{exception.message}")
        Rails.logger.error("[ARGUMENT_ERROR] Params: #{params.to_unsafe_h}")

        if Rails.env.test?
          puts "\n===== Argument Error Details ====="
          puts "Params: #{params.to_unsafe_h}"
          puts "Request body: #{request.raw_post}" if request.raw_post.present?
        end

        render json: {
          errorCode: 400,
          code: "ARGUMENT_ERROR",
          message: exception.message
        }, status: 400

      when CustomError
        # CustomError 상세 로깅
        error_code = exception.respond_to?(:error_code) ? exception.error_code : "C_BAD_REQUEST"

        Rails.logger.error("[CUSTOM_ERROR:#{error_code}] #{exception.message}")
        if exception.respond_to?(:details) && exception.details.present?
          Rails.logger.error("[CUSTOM_ERROR:#{error_code}] Details: #{exception.details}")
        end

        if Rails.env.test?
          puts "\n===== Custom Error Details ====="
          puts "Error Code: #{error_code}"
          puts "Message: #{exception.message}"
          puts "Details: #{exception.details}" if exception.respond_to?(:details)
        end

        render json: {
          errorCode: 400,
          code: error_code,
          message: exception.message
        }, status: 400

      else
        # 예상치 못한 서버 오류 상세 로깅
        Rails.logger.error("[INTERNAL_SERVER_ERROR] #{exception.class}: #{exception.message}")
        Rails.logger.error("[INTERNAL_SERVER_ERROR] Backtrace:")
        exception.backtrace.first(10).each_with_index do |line, i|
          Rails.logger.error("  #{i+1}. #{line}")
        end

        if Rails.env.test?
          puts "\n===== Server Error Details ====="
          puts "Exception: #{exception.class}"
          puts "Message: #{exception.message}"
          puts "Backtrace (first 10 lines):"
          exception.backtrace.first(10).each_with_index do |line, i|
            puts "  #{i+1}. #{line}"
          end
        end

        render json: {
          errorCode: 500,
          code: "INTERNAL_SERVER_ERROR",
          message: "무언가 잘못됐어요."
        }, status: 500
      end
    end
end
