class Views::Pages::Home::GuideSection::MobileFrame::Step02 < Views::Base
  def view_template
    div(class: "flex flex-col gap-3 md:gap-4 p-2") do
      div(class: "flex justify-end text-primary text-[8px] md:text-base underline") do
        "건너뛰기"
      end
      # 로티 컨테이너 (높이 고정값은 수정님한테 맞게 ㄱ)
      div(class: "px-4 md:px-8 relative flex justify-center md:h-[400px]") do
        # 로티 배경 이미지
        img(src: "/images/landing/section02/item09.png")
        # 로티 감싸는 앱솔루트
        div(class: "absolute inset-0") do
          # 요거 로티 컨테이너
          div(data: {
            controller: "lottie",
            "lottie-file-name-value": "a"
          }, class: "h-[180px] md:h-[400px]")
        end
      end
      div(class: "flex justify-center") do
        div(class: "flex justify-center items-center gap-[2px] p-[5px] md:p-[13px] bg-[#2A2C34] rounded-2xl border border-white/20") do
          div(class: "bg-[#515867] rounded-full w-[3px] h-[3px] md:w-[5px] md:h-[5px]")
          div(class: "bg-primary rounded-full w-[8px] h-[3px] md:w-[12px] md:h-[5px]")
          div(class: "bg-[#515867] rounded-full w-[3px] h-[3px] md:w-[5px] md:h-[5px]")
        end
      end
      div(class: "flex gap-1 md:gap-2") do
        div(class: "text-[10px] md:text-lg font-bold") do
          span(class: "text-primary") { "2." }
        end
        div(class: "flex flex-col gap-1") do
          span(class: "text-[10px] md:text-lg font-bold") { "업로드를 눌러주세요." }
          span(class: "text-base-content/50 text-[5px] md:text-[10px]") { "업로드 버튼을 눌러 정리할 스크린샷을 올려주세요!" }
        end
      end
      div(class: "bg-primary rounded-3xl flex items-center justify-center gap-1 p-1 md:p-3 md:h-[50px]") do
        span(class: "text-[5px] md:text-base") { "다음으로" }
        raw(<<~SVG.html_safe)
          <svg class="h-[8px] md:h-[20px]" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
            <path stroke-linecap="round" stroke-linejoin="round" d="m8.25 4.5 7.5 7.5-7.5 7.5" />
          </svg>
        SVG
      end
    end
  end
end
