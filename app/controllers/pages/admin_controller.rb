class Pages::AdminController < PagesController
  before_action :check_ip_whitelist

  layout -> { Layouts::Application.new(
    layout: Pages::Layout.new(
      nav_component: Pages::Admin::Sidebar.new
    )
  ) }

  private

  def check_ip_whitelist
    # 클라우드플레어 대응
    # 1. Cloudflare 특화 헤더를 먼저 확인
    # 2. X-Forwarded-For 헤더에서 실제 클라이언트 IP 추출
    # 3. 그래도 없으면 기본 remote_ip 사용
    client_ip = request.headers["CF-Connecting-IP"] ||
                request.headers["X-Forwarded-For"]&.split(",")&.first&.strip ||
                request.remote_ip

    puts "DEBUG: Client IP: #{client_ip}"  # 디버깅용

    # 로컬호스트 IP는 항상 허용
    return true if [ "127.0.0.1", "::1" ].include?(client_ip)

    # 개발 중에만 추가 IP 허용 (프로덕션에서는 제거할 것)
    return true if Rails.env.development?

    is_whitelisted = IpWhitelist.where(ip: client_ip, is_active: true).exists?

    unless is_whitelisted
      redirect_to access_denied_path(ip: client_ip)
    end
  end
end
