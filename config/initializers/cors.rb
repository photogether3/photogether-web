Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # origins 항목에 허용할 출처(Origin)를 지정합니다.
    # 여러 개를 지정할 수 있습니다.
    # 여기에 앱의 Origin (예: 'capacitor://localhost')과
    # 웹 개발 서버 Origin (예: 'http://localhost:4200') 등을 추가하세요.
    origins "capacitor://localhost", "http://localhost:4200", "https://photogether.app" # <- 여기에 앱의 Origin과 웹 Origin 등을 , 로 구분하여 추가

    # resource 항목은 CORS 설정을 적용할 경로 패턴입니다.
    # '*'는 모든 경로를 의미합니다. '/api/*' 처럼 특정 경로만 지정할 수도 있습니다.
    resource "*",
      headers: :any, # 허용할 요청 헤더 (:any는 모든 헤더 허용)
      methods: [ :get, :post, :put, :patch, :delete, :options, :head ], # 허용할 HTTP 메소드
      credentials: true # 쿠키 등 인증 정보를 포함한 요청을 허용할 경우 true로 설정
    # credentials: true 사용 시 origins에 '*' 사용 불가. 명시적 출처 지정 필요.
    # expose: ['access-token', 'expiry', 'token-type', 'uid', 'client'], # 클라이언트(앱)에서 접근 가능하게 할 응답 헤더 목록 (필요한 경우)
  end
end

puts "[CORS] 설정 초기화 완료"
