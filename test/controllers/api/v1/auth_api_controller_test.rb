require "test_helper"

class Api::V1::AuthApiControllerTest < ActionDispatch::IntegrationTest
  # 공통 헬퍼 메서드 정의
  def setup_test_user(options = {})
    defaults = {
      email: "test@gmail.com",
      password: "1q2w3e4r5t!@",
      update_otp: false,
      verify_email: false,
      with_data: true
    }

    options = defaults.merge(options)

    user_result = Auth::RegisterUser.new(
      email: options[:email],
      password: options[:password]
    ).call
    user = options[:with_data] ? user_result.data : user_result

    otp_result = Auth::OtpProcessor
      .new(email: options[:email])
      .generate(with_otp: true)
      .data if options[:update_otp]
    user.update!(is_email_verified: true) if options[:verify_email]

    {
      user: user,
      email: options[:email],
      password: options[:password],
      otp: otp_result
    }
  end

  # 로그인 토큰 획득 헬퍼
  def get_auth_tokens(email, password)
    post "/api/v1/auth/login", params: { email: email, password: password }
    JSON.parse(response.body)
  end

  describe "회원가입 API" do
    setup do
      # URL 설정
      @register_url = "/api/v1/auth/register"
    end

    test "파라미터 자체를 안넘길 경우 400 에러" do
      post @register_url

      result = JSON.parse(response.body)
      puts result.inspect

      assert_response :bad_request
      assert result.key?("errorCode")
      assert result.key?("code")
      assert result.key?("message")
      assert_includes result["message"], "이메일", "유효성 에러중 첫번 째는 이메일에 대한 에러 반환을 기대"
    end

    test "이메일: 잘못된 이메일 형식은 400 에러" do
      post @register_url, params: {
        email: "invalid-email",
        password: ""
      }

      result = JSON.parse(response.body)
      puts result.inspect

      assert_response :bad_request
      assert result.key?("errorCode")
      assert result.key?("code")
      assert result.key?("message")
      assert_includes result["message"], "이메일", "유효성 에러중 첫번 재는 이메일에 대한 에러 반환을 기대"
      assert_includes result["message"], "유효한", "빈값 에러와는 차별점이 있어야함"
    end

    test "비밀번호: 강력하지 않은 비밀번호는 400 에러" do
      post @register_url, params: {
        email: "test@gmail.com",
        password: "invalid-password"
      }

      result = JSON.parse(response.body)

      assert_response :bad_request
      assert result.key?("errorCode")
      assert result.key?("code")
      assert result.key?("message")
      assert_includes result["message"], "비밀번호"
    end

    test "회원가입 성공" do
      test_email = "test@gmail.com"
      post @register_url, params: {
        email: test_email,
        password: "1q2w3e4r5t!@"
      }

      result = JSON.parse(response.body)
      puts result.inspect

      assert_response :created
      created_user = User.find_by(email_address: test_email)
      assert_not_nil created_user, "사용자가 생성되지 않았습니다"
    end
  end

  describe "로그인 API" do
    setup do
      # URL 설정
      @login_url = "/api/v1/auth/login"

      # 사용자 미리 생성
      test_data = setup_test_user()
      @user = test_data[:user]
      @test_email = test_data[:email]
      @test_password = test_data[:password]

      puts "테스트용 사용자 생성: #{@user.inspect}"
    end

    test "파라미터 자체를 안넘길 경우 400 에러" do
      post @login_url

      result = JSON.parse(response.body)
      puts result.inspect

      assert_response :bad_request
      assert result.key?("errorCode")
      assert result.key?("code")
      assert result.key?("message")
    end

    test "이메일형식이 잘못되었을 경우 400 에러" do
      post @login_url, params: {
        email: "invalid-email"
      }

      result = JSON.parse(response.body)
      puts result.inspect

      assert_response :bad_request
      assert_includes result["message"], "유효한"
      assert_includes result["message"], "이메일"
    end

    test "이메일 미 인증시 400 에러" do
      post @login_url, params: {
        email: @test_email,
        password: @test_password
      }

      result = JSON.parse(response.body)
      puts result.inspect

      assert_response :bad_request
      assert result.key?("errorCode")
      assert result.key?("code")
      assert result.key?("message")
      assert_includes result["message"], "이메일 인증"
    end

    test "로그인 성공" do
      # 이메일이 인증상태로 업데이트
      @user.update!(is_email_verified: true)
      post @login_url, params: {
        email: @test_email,
        password: @test_password
      }

      result = JSON.parse(response.body)
      puts result.inspect

      assert result.key?("accessToken"), "엑세스토큰을 발급해야함"
      assert result.key?("refreshToken"), "리프레시토큰을 발급해야함"
      assert result.key?("expiresIn"), "엑세스토큰 만료기간을 발급해야함"
    end
  end

  describe "이메일로 OTP 코드 발송 API" do
    setup do
      @generate_otp_url = "/api/v1/auth/otp/generate"

      test_data = setup_test_user(with_data: false)
      @user = test_data[:user]
      @test_email = test_data[:email]
      @test_password = test_data[:password]
    end

    test "이메일 형식이 이상한 경우 400 에러" do
      post @generate_otp_url, params: {
        email: "invalid_email"
      }

      result = JSON.parse(response.body)
      puts result.inspect

      assert_response :bad_request
      assert result.key?("errorCode")
      assert result.key?("code")
      assert result.key?("message")
      assert_includes result["message"], "유효한 이메일"
    end

    test "OTP 코드 발급 성공" do
      # 이메일 발송 확인을 위해 deliveries 배열 초기화
      ActionMailer::Base.deliveries.clear

      post @generate_otp_url, params: {
        email: @test_email
      }

      result = JSON.parse(response.body)
      puts result.inspect

      assert_response :ok
      assert result.key?("message")
      assert_includes result["message"], "성공"

      # 이메일 가짜 발송 확인
      sent_email = ActionMailer::Base.deliveries.last
      puts sent_email.to
      assert_equal [ @test_email ], sent_email.to, "이메일이 올바른 주소로 발송되지 않았습니다."
    end
  end

  describe "OTP 검증" do
    setup do
      @verify_otp_url = "/api/v1/auth/otp/verify"

      test_data = setup_test_user(update_otp: true, with_data: false)
      @user = test_data[:user]
      @test_email = test_data[:email]
      @test_password = test_data[:password]

      puts @user.inspect
    end

    test "잘못된 이메일 전달 시 이메일에 관련된 400 에러" do
      post @verify_otp_url, params: {
        email: "invalid_email"
      }

      result = JSON.parse(response.body)
      assert_response :bad_request
      assert result.key?("errorCode")
      assert result.key?("code")
      assert result.key?("message")
      assert_includes result["message"], "이메일"
    end

    test "잘못된 OTP 전달 시 OTP 관련된 400 에러" do
      post @verify_otp_url, params: {
        email: @test_email,
        otp: "123456"
      }

      result = JSON.parse(response.body)
      assert_response :bad_request
      assert result.key?("errorCode")
      assert result.key?("code")
      assert result.key?("message")
      assert_includes result["message"], "OTP"
    end

    test "OTP 검증 성공" do
      post @verify_otp_url, params: {
        email: @test_email,
        otp: @user.otp
      }

      result = JSON.parse(response.body)
      puts result.inspect

      assert_response :ok
      assert result.key?("message")
      assert_includes result["message"], "성공"
    end
  end

  describe "OTP 검증 및 토큰 발급" do
    setup do
      @verify_otp_url = "/api/v1/auth/otp/verify-and-login"

      test_data = setup_test_user(update_otp: true)
      @user = test_data[:user]
      @test_email = test_data[:email]
      @test_password = test_data[:password]
      @otp = test_data[:otp]

      puts @user.inspect
    end

    test "잘못된 이메일 전달 시 이메일에 관련된 400 에러" do
      post @verify_otp_url, params: {
        email: "invalid_email"
      }

      result = JSON.parse(response.body)
      assert_response :bad_request
      assert result.key?("errorCode")
      assert result.key?("code")
      assert result.key?("message")
      assert_includes result["message"], "이메일"
    end

    test "잘못된 OTP 전달 시 OTP 관련된 400 에러" do
      post @verify_otp_url, params: {
        email: @test_email,
        otp: "123456"
      }

      result = JSON.parse(response.body)
      assert_response :bad_request
      assert result.key?("errorCode")
      assert result.key?("code")
      assert result.key?("message")
      assert_includes result["message"], "OTP"
    end

    test "OTP 검증 성공" do
      puts @otp.inspect
      puts @otp.inspect
      puts @otp.inspect
      post @verify_otp_url, params: {
        email: @test_email,
        otp: @otp
      }

      result = JSON.parse(response.body)
      puts result.inspect

      assert_response :ok
      assert result.key?("accessToken")
      assert result.key?("refreshToken")
      assert result.key?("expiresIn")
    end
  end

  describe "토큰 재발급" do
    setup do
      @refresh_url = "/api/v1/auth/refresh"

      # 사용자 생성 및 이메일 인증 처리
      test_data = setup_test_user(verify_email: true)
      @user = test_data[:user]
      @test_email = test_data[:email]
      @test_password = test_data[:password]

      # 로그인하여 토큰 발급
      login_result = get_auth_tokens(@test_email, @test_password)
      @refresh_token = login_result["refreshToken"]

      puts "테스트용 리프레시 토큰: #{@refresh_token.inspect}"
    end

    test "리프레시 토큰 없이 요청 시 400 에러" do
      post @refresh_url

      result = JSON.parse(response.body)
      puts result.inspect

      assert_response :bad_request
      assert result.key?("errorCode")
      assert result.key?("code")
      assert result.key?("message")
      assert_includes result["message"], "리프레시 토큰"
    end

    test "유효하지 않은 리프레시 토큰으로 요청 시 400 에러" do
      post @refresh_url, headers: {
        "x-refresh-token": "invalid_refresh_token"
      }

      result = JSON.parse(response.body)
      puts result.inspect

      assert_response :bad_request
      assert result.key?("errorCode")
      assert result.key?("code")
      assert result.key?("message")
      assert_includes result["message"], "유효하지 않습니다"
    end

    test "유효한 리프레시 토큰으로 토큰 재발급 성공" do
      post @refresh_url, headers: {
        "x-refresh-token": @refresh_token
      }

      result = JSON.parse(response.body)
      puts result.inspect

      assert_response :ok
      assert result.key?("accessToken"), "새 액세스 토큰이 발급되어야 함"
      assert result.key?("refreshToken"), "새 리프레시 토큰이 발급되어야 함"
      assert result.key?("expiresIn"), "토큰 만료 시간이 포함되어야 함"
    end
  end

  describe "로그아웃" do
    setup do
      @logout_url = "/api/v1/auth/logout"

      # 사용자 생성 및 이메일 인증 처리
      test_data = setup_test_user(verify_email: true)
      @user = test_data[:user]
      @test_email = test_data[:email]
      @test_password = test_data[:password]

      # 로그인하여 토큰 발급
      login_result = get_auth_tokens(@test_email, @test_password)
      @access_token = login_result["accessToken"]

      puts "테스트용 액세스 토큰: #{@access_token.inspect}"
    end

    test "액세스 토큰 없이 로그아웃 시도 시 401 에러" do
      delete @logout_url

      result = JSON.parse(response.body)
      puts result.inspect

      assert_response :unauthorized
      assert result.key?("errorCode")
      assert result.key?("code")
      assert result.key?("message")
    end

    test "잘못된 액세스 토큰으로 로그아웃 시도 시 401 에러" do
      delete @logout_url, headers: {
        "Authorization": "Bearer invalid_access_token"
      }

      result = JSON.parse(response.body)
      puts result.inspect

      assert_response :unauthorized
      assert result.key?("errorCode")
      assert result.key?("code")
      assert result.key?("message")
    end

    test "유효한 액세스 토큰으로 로그아웃 성공" do
      delete @logout_url, headers: {
        "Authorization": "Bearer #{@access_token}"
      }

      result = JSON.parse(response.body)
      puts result.inspect

      assert_response :ok
      assert result.key?("message")
      assert_includes result["message"], "로그아웃"

      # 리프레시토큰이 제거 되었는지 확인
      refresh_token = @user.refresh_token
      puts refresh_token.inspect
      assert_nil refresh_token
    end
  end
end
