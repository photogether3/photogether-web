class Views::Pages::Admin::Sidebar < Views::Base
  def view_template
    # 사이드바
    aside(
      class: "sticky top-0 border-r border-dashed border-base-300 h-full w-[30%] min-w-[300px]
      flex flex-col items-end justify-center p-4") do
      div(class: "flex flex-col items-center gap-6") do
        ul(class: "flex flex-col gap-4") do
          li do
            a(href: "/admin",
              class: "flex flex-col gap-2 text-xs items-center p-2 rounded-md bg-base-200") do
              raw(<<~SVG.html_safe)
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
                  <path stroke-linecap="round" stroke-linejoin="round" d="m2.25 12 8.954-8.955c.44-.439 1.152-.439 1.591 0L21.75 12M4.5 9.75v10.125c0 .621.504 1.125 1.125 1.125H9.75v-4.875c0-.621.504-1.125 1.125-1.125h2.25c.621 0 1.125.504 1.125 1.125V21h4.125c.621 0 1.125-.504 1.125-1.125V9.75M8.25 21h8.25" />
                </svg>
              SVG
              span { "대시보드" }
            end
          end
          li do
            a(href: "/admin/users",
              class: "flex flex-col gap-2 text-xs items-center p-2 rounded-md") do
              raw(<<~SVG.html_safe)
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M15 19.128a9.38 9.38 0 0 0 2.625.372 9.337 9.337 0 0 0 4.121-.952 4.125 4.125 0 0 0-7.533-2.493M15 19.128v-.003c0-1.113-.285-2.16-.786-3.07M15 19.128v.106A12.318 12.318 0 0 1 8.624 21c-2.331 0-4.512-.645-6.374-1.766l-.001-.109a6.375 6.375 0 0 1 11.964-3.07M12 6.375a3.375 3.375 0 1 1-6.75 0 3.375 3.375 0 0 1 6.75 0Zm8.25 2.25a2.625 2.625 0 1 1-5.25 0 2.625 2.625 0 0 1 5.25 0Z" />
                </svg>
              SVG
              span { "회원관리" }
            end
          end
        end
      end
    end
  end
end
