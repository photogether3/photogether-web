class Views::Pages::Sidebar < Views::Base
  def initialize
    @home_path = "/"
    @login_path = "/session/login"
  end

  def view_template
    div(class: "flex flex-col items-center gap-6") do
      ul(class: "flex flex-col gap-4") do
        li do
          a(href: @home_path,
            class: "flex flex-col gap-2 w-16 text-xs items-center p-2 rounded-md #{current_path?(@home_path) && 'bg-primary border-base-300 text-white' } ") do
            raw(<<~SVG.html_safe)
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
                <path stroke-linecap="round" stroke-linejoin="round" d="m2.25 12 8.954-8.955c.44-.439 1.152-.439 1.591 0L21.75 12M4.5 9.75v10.125c0 .621.504 1.125 1.125 1.125H9.75v-4.875c0-.621.504-1.125 1.125-1.125h2.25c.621 0 1.125.504 1.125 1.125V21h4.125c.621 0 1.125-.504 1.125-1.125V9.75M8.25 21h8.25" />
              </svg>
            SVG
            span { "홈" }
          end
        end
        li do
          a(href: @login_path,
            class: "flex flex-col gap-2 text-xs items-center p-2 rounded-md #{current_path?(@login_path, start_with: true) && 'bg-primary border-base-300 text-white' }") do
            raw(<<~SVG.html_safe)
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
                <path stroke-linecap="round" stroke-linejoin="round" d="M15.75 9V5.25A2.25 2.25 0 0 0 13.5 3h-6a2.25 2.25 0 0 0-2.25 2.25v13.5A2.25 2.25 0 0 0 7.5 21h6a2.25 2.25 0 0 0 2.25-2.25V15M12 9l-3 3m0 0 3 3m-3-3h12.75" />
              </svg>
            SVG
            div(class: "text-center") do
              p { "로그인" }
            end
          end
        end
      end
    end
  end
end
