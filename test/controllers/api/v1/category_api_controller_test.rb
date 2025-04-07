require "test_helper"

class Api::V1::CategoryApiControllerTest < ActionDispatch::IntegrationTest
  describe "카테고리 목록 조회 API" do
    test "카테고리 목록 조회 성공" do
      get "/api/v1/categories"

      results = JSON.parse(response.body)
      puts results.inspect
      puts results.length

      assert_response :ok
      assert results.is_a?(Array), "반환값은 배열이어야합니다."
      assert results.length >= 10, "카테고리는 최소 10개 이상이어야 합니다"

      item = results.first
      puts item.inspect
      assert item.key?("id"), "카테고리의 id 속성은 필수반환값 입니다."
      assert item.key?("name"), "카테고리의 name 속성은 필수반환값 입니다."
    end
  end

  describe "현재 사용자의 관심 카테고리 목록 조회 API" do
    setup do
      # 테스트 계정 생성
      test_email    = "dev.goraebap@gmail.com"
      test_password = "1q2w3e4r5t!"
      @user = User.register(email: test_email, password: test_password)
      @user.update!(is_email_verified: true)

      # 로그인 API 호출로 토큰 발급
      post "/api/v1/auth/login", params: {
        email: test_email,
        password: test_password
      }
      result = JSON.parse(response.body)
      puts result.inspect

      # 엑세스토큰 저장
      @act = result["accessToken"]

      # 카테고리별 관심 카테고리 상태 조회 URL 설정
      @with_favorite_status_url = "/api/v1/categories/with-favorite-status"
    end

    test "유효하지 않은 엑세스토큰은 401 에러" do
      get @with_favorite_status_url
      assert_response :unauthorized
    end

    test "관심 카테고리 목록 조회 성공" do
      get @with_favorite_status_url, headers: {
        "Authorization": "Bearer #{@act}"
      }

      results = JSON.parse(response.body)
      puts results.inspect

      assert_response :ok
      assert results.is_a?(Array)
      assert results.length >= 10, "카테고리는 최소 10개 이상이어야 합니다"

      item = results.first
      assert item.key?("id")
      assert item.key?("name")
      assert item.key?("isFavorite")
    end
  end
end
