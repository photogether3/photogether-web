class Views::Pages::Sidebar < Views::Base
  def initialize
    @home_path = "/"
    @policies_data_deletion_path = "/policies/data-deletion"
    @policies_terms_path = "/policies/1"
    @policies_privacy_path = "/policies/2"
  end

  def view_template
    div(class: "flex flex-col items-center gap-6") do
      ul(class: "flex flex-col gap-4") do
        li do
          a(href: @home_path,
            class: "flex flex-col gap-2 text-xs items-center p-2 rounded-md #{current_path?(@home_path) && 'bg-primary/70 border-base-300 text-white' } ") do
            raw(<<~SVG.html_safe)
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
                <path stroke-linecap="round" stroke-linejoin="round" d="m2.25 12 8.954-8.955c.44-.439 1.152-.439 1.591 0L21.75 12M4.5 9.75v10.125c0 .621.504 1.125 1.125 1.125H9.75v-4.875c0-.621.504-1.125 1.125-1.125h2.25c.621 0 1.125.504 1.125 1.125V21h4.125c.621 0 1.125-.504 1.125-1.125V9.75M8.25 21h8.25" />
              </svg>
            SVG
            span { "홈" }
          end
        end
        li do
          a(href: @policies_terms_path,
            class: "flex flex-col gap-2 text-xs items-center p-2 rounded-md #{current_path?(@policies_terms_path, start_with: true) && 'bg-primary/70 border-base-300 text-white' }") do
            raw(<<~SVG.html_safe)
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
                <path stroke-linecap="round" stroke-linejoin="round" d="M12 21v-8.25M15.75 21v-8.25M8.25 21v-8.25M3 9l9-6 9 6m-1.5 12V10.332A48.36 48.36 0 0 0 12 9.75c-2.551 0-5.056.2-7.5.582V21M3 21h18M12 6.75h.008v.008H12V6.75Z" />
              </svg>
            SVG
            div(class: "text-center") do
              p { "서비스" }
              p { "약관" }
            end
          end
        end
        li do
          a(href: @policies_privacy_path,
            class: "flex flex-col gap-2 text-xs items-center p-2 rounded-md #{current_path?(@policies_privacy_path, start_with: true) && 'bg-primary/70 border-base-300 text-white' }") do
            raw(<<~SVG.html_safe)
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
                <path stroke-linecap="round" stroke-linejoin="round" d="M3.98 8.223A10.477 10.477 0 0 0 1.934 12C3.226 16.338 7.244 19.5 12 19.5c.993 0 1.953-.138 2.863-.395M6.228 6.228A10.451 10.451 0 0 1 12 4.5c4.756 0 8.773 3.162 10.065 7.498a10.522 10.522 0 0 1-4.293 5.774M6.228 6.228 3 3m3.228 3.228 3.65 3.65m7.894 7.894L21 21m-3.228-3.228-3.65-3.65m0 0a3 3 0 1 0-4.243-4.243m4.242 4.242L9.88 9.88" />
              </svg>
            SVG
            div(class: "text-center") do
              p { "개인정보" }
              p { "처리약관" }
            end
          end
        end
        li do
          a(href: @policies_data_deletion_path,
            class: "flex flex-col gap-2 text-xs items-center p-2 rounded-md #{current_path?(@policies_data_deletion_path, start_with: true) && 'bg-primary/70 border-base-300 text-white' }") do
            raw(<<~SVG.html_safe)
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
                <path stroke-linecap="round" stroke-linejoin="round" d="M22 10.5h-6m-2.25-4.125a3.375 3.375 0 1 1-6.75 0 3.375 3.375 0 0 1 6.75 0ZM4 19.235v-.11a6.375 6.375 0 0 1 12.75 0v.109A12.318 12.318 0 0 1 10.374 21c-2.331 0-4.512-.645-6.374-1.766Z" />
              </svg>
            SVG
            div(class: "text-center") do
              p { "계청삭제" }
              p { "처리약관" }
            end
          end
        end
      end
    end
  end
end
