class Views::Pages::Users::Sidebar < Views::Base
  def initialize
    @my_path = "/users/me"
    @my_feedbacks_path = "/users/me/feedbacks"
  end

  def view_template
    div(class: "flex flex-col items-center gap-6") do
      ul(class: "flex flex-col gap-4") do
        li do
          a(href: @my_path,
            class: "flex flex-col gap-2 text-xs items-center p-2 rounded-md #{current_path?(@my_path) && 'bg-primary border-base-300 text-white' } ") do
            raw(<<~SVG.html_safe)
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
                <path stroke-linecap="round" stroke-linejoin="round" d="m2.25 12 8.954-8.955c.44-.439 1.152-.439 1.591 0L21.75 12M4.5 9.75v10.125c0 .621.504 1.125 1.125 1.125H9.75v-4.875c0-.621.504-1.125 1.125-1.125h2.25c.621 0 1.125.504 1.125 1.125V21h4.125c.621 0 1.125-.504 1.125-1.125V9.75M8.25 21h8.25" />
              </svg>
            SVG
            span { "내 정보" }
          end
        end
        li do
          a(href: @my_feedbacks_path,
            class: "flex flex-col gap-2 text-xs items-center p-2 rounded-md #{current_path?(@my_feedbacks_path, start_with: true) && 'bg-primary border-base-300 text-white' }") do
            raw(<<~SVG.html_safe)
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
                <path stroke-linecap="round" stroke-linejoin="round" d="M12 21v-8.25M15.75 21v-8.25M8.25 21v-8.25M3 9l9-6 9 6m-1.5 12V10.332A48.36 48.36 0 0 0 12 9.75c-2.551 0-5.056.2-7.5.582V21M3 21h18M12 6.75h.008v.008H12V6.75Z" />
              </svg>
            SVG
            div(class: "text-center") do
              p { "개선의견" }
            end
          end
        end
      end
    end
  end
end
