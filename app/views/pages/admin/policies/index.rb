class Views::Pages::Admin::Policies::Index < Views::Base
  include Views::Pages::Admin

  def initialize(policies:)
    puts policies.inspect
    @policies = policies
  end

  def view_template
    render Layout.new do
      h1(class: "text-3xl font-bold") { "약관 관리" }
      br(class: "my-10")
      div(class: "overflow-x-auto border border-base-200 bg-base-100") do
        table(class: "table") do
          thead(class: "bg-base-200") do
            tr do
              th
              th { "제목" }
              th { "구분" }
              th { "버전" }
              th { "활성여부" }
              th { "정책활성일자" }
              th { "필수동의여부" }
              th
            end
          end
          tbody do
            @policies.each_with_index do |policy, i|
              tr do
                td { i+1 }
                td do
                  a(href: "/admin/policies/#{policy[:id]}",
                  class: "text-primary") { policy[:title] }
                end
                td do
                  span(class: "badge badge-secondary text-xs font-semibold text-white") { policy[:kind].upcase }
                end
                td { policy[:version] }
                td { policy[:is_active] ? "활성" : "비활성" }
                td { policy[:effective_date]&.strftime("%Y-%m-%d") || "없음" }
                td { policy[:is_required] ? "필수" : "선택" }
                td do
                  a(
                    href: "/admin/policies/#{policy[:id]}/edit",
                    class: "text-xs text-gray-700") do
                    raw(<<~SVG.html_safe)
                      <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
                        <path stroke-linecap="round" stroke-linejoin="round" d="m16.862 4.487 1.687-1.688a1.875 1.875 0 1 1 2.652 2.652L10.582 16.07a4.5 4.5 0 0 1-1.897 1.13L6 18l.8-2.685a4.5 4.5 0 0 1 1.13-1.897l8.932-8.931Zm0 0L19.5 7.125M18 14v4.75A2.25 2.25 0 0 1 15.75 21H5.25A2.25 2.25 0 0 1 3 18.75V8.25A2.25 2.25 0 0 1 5.25 6H10" />
                      </svg>
                    SVG
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
