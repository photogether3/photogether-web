class Views::Pages::Session::Login < Views::Base
  def initialize(credentials: nil)
    @credentials = credentials
    puts "<<<<<<<<<<<<<<<<<<<<"
    puts @credentials
    puts "<<<<<<<<<<<<<<<<<<<<"
  end

  def view_template
    div(class: "p-6 flex items-center gap-2") do
      a(href: "/",
        class: "text-xl") do
        raw(<<~SVG.html_safe)
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
            <path stroke-linecap="round" stroke-linejoin="round" d="M10.5 19.5 3 12m0 0 7.5-7.5M3 12h18" />
          </svg>
        SVG
      end
      h2(class: "text-2xl") { "로그인" }
    end
    form(action: "/session/login", method: "post") do
      div(class: "p-6 border-t border-dashed border-base-300 flex flex-col gap-4") do
        fieldset(class: "fieldset") do
          legend(class: "fieldset-legend text-sm") { "아이디" }
          input(
            class: "input",
            placeholder: "아이디를 입력해 주세요",
            name: "credentials[email]",
            value: @credentials&.dig("email"))
        end

        fieldset(class: "fieldset") do
          legend(class: "fieldset-legend text-sm") { "비밀번호" }
          input(
            class: "input",
            type: "password",
            placeholder: "비밀번호를 입력해 주세요",
            name: "credentials[password]",
            value: @credentials&.dig("password"))
        end
      end

      div(class: "p-6 border-t border-dashed border-base-300") do
        button(class: "btn btn-soft btn-primary") { "로그인" }
      end
    end
  end
end
