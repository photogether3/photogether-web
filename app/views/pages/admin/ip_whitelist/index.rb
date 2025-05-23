class Views::Pages::Admin::IpWhitelist::Index < Views::Base
  def initialize(ip_whitelist: nil)
    @ip_whitelist = ip_whitelist
  end

  def view_template
    div(class: "p-6 flex justify-between items-center") do
      h1(class: "text-2xl") { "접근관리" }
      a(href: "/admin/ip-whitelist/new", class: "btn btn-soft btn-primary") { "접근허용 IP추가" }
    end
    div(class: "p-6 border-t border-dashed border-base-300") do
      @ip_whitelist.inspect
    end
  end
end
