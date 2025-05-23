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
      table(class: "table table-sm") do
        thead(class: "bg-base-200") do
          th { "" }
          th { "IP 주소" }
          th { "설명" }
          th { "활성여부" }
          th { "생성일자" }
          th { "" }
        end
        tbody do
          @ip_whitelist.each_with_index do |ip_item, i|
            tr do
              td { i+1 }
              td { ip_item[:ip] }
              td { ip_item[:description] }
              td { ip_item[:is_active] ? "활성" : "비활성" }
              td { ip_item[:created_at]&.strftime("%Y-%m-%d %H:%M:%S") }
              td do
                a(href: "/admin/ip-whitelist/#{ip_item[:id]}",
                  class: "btn btn-soft btn-error",
                  data: {
                    turbo_method: "delete",
                    turbo_confirm: "정말로 이 IP를 삭제하시겠습니까?"
                  }) { "삭제" }
              end
            end
          end
        end
      end
    end
  end
end
