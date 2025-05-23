class Views::Pages::Layout < Views::Base
  def initialize(
    title: "포토게더",
    content_padding: true
  )
    @title = title
    # 기본적으로는 컨텐츠 영역에 패딩이 들어가있음
    # 레이아웃을 사용하는 시점에 명시적으로 false 값을 주어 패딩을 사용하지 않을 수 있음
    @content_padding = content_padding
  end

  def view_template
    # 전체 컨테이너에 상대 위치 설정
    div(class: "flex flex-col h-screen relative") do
      # 알림박스
      div(class: "h-[56px] border-b border-base-300 flex justify-center items-center p-3 gap-2 bg-primary/10 relative z-10") do
        div(class: "flex items-center gap-2") do
          # 정보 아이콘 추가
          raw(<<~SVG.html_safe)
            <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-primary" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
          SVG

          span { "포토게더가 성장하는 중! " }
          span(class: "font-semibold text-primary") { "여러분의 의견" }
          span { "이 필요합니다. " }

          a(href: "/feedback", class: "text-primary underline font-bold hover:text-primary-focus") { "피드백 남기기" }
        end
      end

      # 컨텐츠 영역
      div(class: "h-[calc(100%-56px)] flex flex-col z-10 relative") do
        # 메인 컨텐츠
        div(class: "mx-auto container max-w-5xl flex-grow border-x-2 border-dashed border-base-300") do
          header(class: "p-6 h-24") do
            a(href: "/", class: "") do
              img(src: "/images/photogether-logo.png", class: "h-full")
            end
          end
          main do
            yield
          end
        end

        # 푸터
        footer(class: "footer footer-center p-6 text-base-content w-full bg-primary/10 border-t border-base-300") do
          div(class: "mx-auto container max-w-5xl flex justify-between px-6") do
            div(class: "flex gap-2") do
              p(class: "mr-3") { "© 2025 AZA, Inc. All rights reserved." }
              a(class: "text-primary") { "Terms" }
              a(class: "text-primary") { "Privacy" }
            end

            a(href: "https://github.com/photogether3", class: "link link-hover flex items-center") do
              raw(<<~SVG.html_safe)
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="currentColor" class="mr-2">
                  <path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z"></path>
                </svg>
              SVG
              span { "GitHub" }
            end
          end
        end
      end
    end
  end
end
