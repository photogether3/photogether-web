class Views::Pages::Access::Denied < Views::Base
  def initialize(client_ip:)
    @client_ip = client_ip
  end

  def view_template
    div(class: "min-h-screen flex flex-col items-center justify-center p-6") do
      div(class: "max-w-md w-full bg-base-100 border border-base-300 rounded-lg p-8 text-center") do
        div(class: "text-error mb-6") do
          raw(<<~SVG.html_safe)
            <svg xmlns="http://www.w3.org/2000/svg" class="h-24 w-24 mx-auto" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
            </svg>
          SVG
        end

        h1(class: "text-2xl font-bold mb-4") { "접근이 차단되었습니다" }

        p(class: "mb-6 text-base-content/70") do
          "관리자 페이지에 접근하기 위해서는 IP 주소가 화이트리스트에 등록되어 있어야 합니다."
        end

        p(class: "text-sm") { @client_ip }

        a(href: "/", class: "btn btn-error mt-10") { "홈으로 돌아가기" }
      end

      div(class: "mt-8 text-sm text-base-content/50") do
        p { "접근 권한이 필요하신 경우 관리자에게 문의하세요." }
      end
    end
  end
end
