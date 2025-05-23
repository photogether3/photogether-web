class Views::Pages::Admin::IpWhitelist::New < Views::Base
  def initialize(ip_whitelist: nil)
    @ip_whitelist = ip_whitelist
  end

  def view_template
    div(class: "p-6 flex items-center gap-2") do
      a(href: "/admin/ip-whitelist",
        class: "text-xl") do
        raw(<<~SVG.html_safe)
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
            <path stroke-linecap="round" stroke-linejoin="round" d="M10.5 19.5 3 12m0 0 7.5-7.5M3 12h18" />
          </svg>
        SVG
      end
      h2(class: "text-2xl") { "접근 허용 IP 추가" }
    end
    form(action: "/admin/ip-whitelist", method: "post") do
      div(class: "flex flex-col gap-4 p-6 border-t border-dashed border-base-300") do
        fieldset do
          legend(class: "fieldset-legend text-xs") { "ip 주소" }
          input(name: "ip_whitelist[ip]", class: "input", placeholder: "IP 주소를 입력해 주세요.", value: @ip_whitelist[:ip] || "")
        end
        fieldset do
          legend(class: "fieldset-legend text-xs") { "간단한 설명" }
          input(name: "ip_whitelist[description]", class: "input", placeholder: "간단한 설명을 입력해주세요. (누구의 IP인지)", value: @ip_whitelist[:description] || "")
        end
      end
      div(class: "p-6 border-t border-dashed border-base-300") do
        button(class: "btn btn-soft btn-primary") { "추가하기" }
      end
    end
  end
end
