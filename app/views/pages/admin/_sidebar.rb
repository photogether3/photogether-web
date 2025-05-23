class Views::Pages::Admin::Sidebar < Views::Base
  def initialize
    @admin_dashboard_path = "/admin"
    @admin_users_path = "/admin/users"
    @admin_polices_path = "/admin/policies"
    @admin_ip_whitelist_path = "/admin/ip-whitelist"
  end

  def view_template
    div(class: "flex flex-col items-center gap-6") do
      ul(class: "flex flex-col gap-4") do
        li do
          a(href: @admin_dashboard_path,
            class: "flex flex-col gap-2 text-xs items-center p-2 rounded-md #{current_path?(@admin_dashboard_path) && 'bg-primary/70 border-base-300 text-white' } ") do
            raw(<<~SVG.html_safe)
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
                <path stroke-linecap="round" stroke-linejoin="round" d="m2.25 12 8.954-8.955c.44-.439 1.152-.439 1.591 0L21.75 12M4.5 9.75v10.125c0 .621.504 1.125 1.125 1.125H9.75v-4.875c0-.621.504-1.125 1.125-1.125h2.25c.621 0 1.125.504 1.125 1.125V21h4.125c.621 0 1.125-.504 1.125-1.125V9.75M8.25 21h8.25" />
              </svg>
            SVG
            span { "대시보드" }
          end
        end
        li do
          a(href: @admin_users_path,
            class: "flex flex-col gap-2 text-xs items-center p-2 rounded-md #{current_path?(@admin_users_path, start_with: true) && 'bg-primary/70 border-base-300 text-white' }") do
            raw(<<~SVG.html_safe)
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
                <path stroke-linecap="round" stroke-linejoin="round" d="M15 19.128a9.38 9.38 0 0 0 2.625.372 9.337 9.337 0 0 0 4.121-.952 4.125 4.125 0 0 0-7.533-2.493M15 19.128v-.003c0-1.113-.285-2.16-.786-3.07M15 19.128v.106A12.318 12.318 0 0 1 8.624 21c-2.331 0-4.512-.645-6.374-1.766l-.001-.109a6.375 6.375 0 0 1 11.964-3.07M12 6.375a3.375 3.375 0 1 1-6.75 0 3.375 3.375 0 0 1 6.75 0Zm8.25 2.25a2.625 2.625 0 1 1-5.25 0 2.625 2.625 0 0 1 5.25 0Z" />
              </svg>
            SVG
            span { "회원관리" }
          end
        end
        li do
          a(href: @admin_polices_path,
            class: "flex flex-col gap-2 text-xs items-center p-2 rounded-md #{current_path?(@admin_polices_path, start_with: true) && 'bg-primary/70 border-base-300 text-white' }") do
            raw(<<~SVG.html_safe)
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
                <path stroke-linecap="round" stroke-linejoin="round" d="M19.5 14.25v-2.625a3.375 3.375 0 0 0-3.375-3.375h-1.5A1.125 1.125 0 0 1 13.5 7.125v-1.5a3.375 3.375 0 0 0-3.375-3.375H8.25m0 12.75h7.5m-7.5 3H12M10.5 2.25H5.625c-.621 0-1.125.504-1.125 1.125v17.25c0 .621.504 1.125 1.125 1.125h12.75c.621 0 1.125-.504 1.125-1.125V11.25a9 9 0 0 0-9-9Z" />
              </svg>
            SVG
            span { "약관관리" }
          end
        end
        li do
          a(href: @admin_ip_whitelist_path,
            class: "flex flex-col gap-2 text-xs items-center p-2 rounded-md #{current_path?(@admin_ip_whitelist_path, start_with: true) && 'bg-primary/70 border-base-300 text-white' }") do
            raw(<<~SVG.html_safe)
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
                <path stroke-linecap="round" stroke-linejoin="round" d="M19.5 14.25v-2.625a3.375 3.375 0 0 0-3.375-3.375h-1.5A1.125 1.125 0 0 1 13.5 7.125v-1.5a3.375 3.375 0 0 0-3.375-3.375H8.25m0 12.75h7.5m-7.5 3H12M10.5 2.25H5.625c-.621 0-1.125.504-1.125 1.125v17.25c0 .621.504 1.125 1.125 1.125h12.75c.621 0 1.125-.504 1.125-1.125V11.25a9 9 0 0 0-9-9Z" />
              </svg>
            SVG
            span { "접근관리" }
          end
        end
      end
    end
  end
end
