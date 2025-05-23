class Pages::AdminController < PagesController
  before_action :check_ip_whitelist

  layout -> { Layouts::Application.new(
    layout: Pages::Layout.new(
      nav_component: Pages::Admin::Sidebar.new
    )
  ) }

  private

  def check_ip_whitelist
    client_ip = request.remote_ip

    # 로컬호스트 IP(IPv4: 127.0.0.1, IPv6: ::1)는 항상 허용
    return true if [ "127.0.0.1", "::1" ].include?(client_ip)

    is_whitelisted = IpWhitelist.where(ip: client_ip, is_active: true).exists?

    unless is_whitelisted
      redirect_to access_denied_path(ip: client_ip)
    end
  end
end
