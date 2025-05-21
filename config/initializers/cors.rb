Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # origins 항목에 허용할 출처(Origin)를 지정합니다.
    origins "capacitor://localhost", "ionic://localhost",
            "http://localhost", "https://localhost",
            "http://localhost:4200", "https://localhost:4200",
            "http://10.0.2.2", "https://photogether.app",
            "capacitor://photogether.app", "ionic://photogether.app",
            # 추가 항목
            "capacitor://photogether.store",
            "ionic://photogether.store",
            "capacitor://photogether-app",
            "ionic://photogether-app",
            "file://",  # iOS에서 일부 WebView 설정에 필요할 수 있음
            "null"      # 일부 네이티브 앱 요청에서 null origin 사용

    # resource 항목은 CORS 설정을 적용할 경로 패턴입니다.
    resource "*",
      headers: :any,
      methods: [ :get, :post, :put, :patch, :delete, :options, :head ],
      credentials: true,
      expose: [
        "Access-Control-Allow-Origin",
        "Access-Control-Allow-Credentials",
        "Access-Control-Allow-Methods",  # 메소드도 노출
        "Content-Type",
        "Authorization"
      ]
  end

  # 프로덕션 환경에서도 모든 출처 허용 (테스트용, 나중에 비활성화 권장)
  allow do
    origins "*"
    resource "*",
      headers: :any,
      methods: [ :get, :post, :put, :patch, :delete, :options, :head ],
      credentials: false
  end
end

puts "[CORS] 설정 초기화 완료"
