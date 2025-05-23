class Views::Pages::Home::Index < Views::Base
  def view_template
    div(class: "flex flex-col gap-10 p-6") do
      # 히어로 이미지
      img(src: "/images/hero_content.png", class: "rounded-box")

      # 앱 소개 및 다운로드 섹션
      section(class: "py-12 flex flex-col items-center") do
        div(class: "text-center max-w-2xl mb-10") do
          h2(class: "text-3xl font-bold mb-4") { "쇼핑 전, 캡처한 사진들 어디 있나요?" }
          p(class: "text-xl opacity-80") { "포토게더로 쇼핑 캡처, 구매 내역, 상품 정보를 한 곳에서 관리하세요." }
        end

        # 앱 다운로드 버튼
        div(class: "flex flex-wrap justify-center gap-4") do
          # 플레이스토어 버튼
          a(href: "#", class: "btn btn-primary gap-2") do
            raw(<<~SVG.html_safe)
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
                <path stroke-linecap="round" stroke-linejoin="round" d="M5.25 5.653c0-.856.917-1.398 1.667-.986l11.54 6.347a1.125 1.125 0 0 1 0 1.972l-11.54 6.347a1.125 1.125 0 0 1-1.667-.986V5.653Z" />
              </svg>
            SVG
            span { "Google Play 다운로드" }
          end

          # 앱스토어 버튼
          a(href: "#", class: "btn btn-primary gap-2") do
            raw(<<~SVG.html_safe)
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
                <path stroke-linecap="round" stroke-linejoin="round" d="M13.5 21v-7.5a.75.75 0 0 1 .75-.75h3a.75.75 0 0 1 .75.75V21m-4.5 0H2.36m11.14 0H18m0 0h3.64m-1.39 0V9.349M3.75 21V9.349m0 0a3.001 3.001 0 0 0 3.75-.615A2.993 2.993 0 0 0 9.75 9.75c.896 0 1.7-.393 2.25-1.016a2.993 2.993 0 0 0 2.25 1.016c.896 0 1.7-.393 2.25-1.015a3.001 3.001 0 0 0 3.75.614m-16.5 0a3.004 3.004 0 0 1-.621-4.72l1.189-1.19A1.5 1.5 0 0 1 5.378 3h13.243a1.5 1.5 0 0 1 1.06.44l1.19 1.189a3 3 0 0 1-.621 4.72M6.75 18h3.75a.75.75 0 0 0 .75-.75V13.5a.75.75 0 0 0-.75-.75H6.75a.75.75 0 0 0-.75.75v3.75c0 .414.336.75.75.75Z" />
              </svg>
            SVG
            span { "App Store 다운로드" }
          end
        end
      end

      # 기능 하이라이트 섹션
      section(class: "py-8 grid grid-cols-1 md:grid-cols-3 gap-6") do
        # 기능 1
        div(class: "card bg-base-300 shadow-md hover:shadow-lg transition-shadow") do
          div(class: "card-body") do
            div(class: "text-primary mb-4") do
              raw(<<~SVG.html_safe)
                <svg xmlns="http://www.w3.org/2000/svg" class="size-8" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                </svg>
              SVG
            end
            h3(class: "card-title") { "이미지 정리" }
            p { "쇼핑 중 캡처한 사진들을 한 곳에서 편리하게 관리하세요." }
          end
        end

        # 기능 2
        div(class: "card bg-base-300 shadow-md hover:shadow-lg transition-shadow") do
          div(class: "card-body") do
            div(class: "text-primary mb-4") do
              raw(<<~SVG.html_safe)
                <svg xmlns="http://www.w3.org/2000/svg" class="size-8" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z" />
                </svg>
              SVG
            end
            h3(class: "card-title") { "태그 및 분류" }
            p { "상품별로 태그를 추가하고 카테고리로 구분하여 쉽게 찾을 수 있습니다." }
          end
        end

        # 기능 3
        div(class: "card bg-base-300 shadow-md hover:shadow-lg transition-shadow") do
          div(class: "card-body") do
            div(class: "text-primary mb-4") do
              raw(<<~SVG.html_safe)
                <svg xmlns="http://www.w3.org/2000/svg" class="size-8" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                </svg>
              SVG
            end
            h3(class: "card-title") { "개인화된 경험" }
            p { "사용자의 쇼핑 습관에 맞는 맞춤형 분류와 알림 기능을 제공합니다." }
          end
        end
      end

      # 앱 다운로드 CTA 섹션
      section(class: "py-10 text-center bg-primary/10 rounded-box p-8") do
        h2(class: "text-2xl font-bold mb-4") { "지금 바로 포토게더를 시작하세요!" }
        p(class: "mb-6 max-w-xl mx-auto") { "쇼핑 캡처 관리를 위한 최고의 선택, 포토게더와 함께 더 스마트한 쇼핑 경험을 만나보세요." }

        div(class: "flex flex-wrap justify-center gap-4") do
          a(href: "#", class: "btn") { "더 알아보기" }
          a(href: "#", class: "btn btn-primary") { "무료로 시작하기" }
        end
      end

      div(class: "mb-10")
    end
  end
end
