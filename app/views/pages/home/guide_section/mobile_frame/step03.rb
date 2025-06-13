class Views::Pages::Home::GuideSection::MobileFrame::Step03 < Views::Base
  def view_template
    div(class: "flex flex-col gap-3 md:gap-4 p-2") do
      div(class: "flex justify-end text-primary text-[8px] md:text-base underline") do
        "건너뛰기"
      end
      div(class: "px-4 md:px-8") do
        div(data: {
          controller: "lottie",
          "lottie-file-name-value": "onb3"
        }, class: "md:h-[400px]")
      end
      div(class: "flex justify-center") do
        div(class: "flex justify-center items-center gap-[2px] p-[5px] md:p-[13px] bg-[#2A2C34] rounded-2xl border border-white/20") do
          div(class: "bg-[#515867] rounded-full w-[3px] h-[3px] md:w-[5px] md:h-[5px]")
          div(class: "bg-[#515867] rounded-full w-[3px] h-[3px] md:w-[5px] md:h-[5px]")
          div(class: "bg-primary rounded-full w-[8px] h-[3px] md:w-[12px] md:h-[5px]")
        end
      end
      div(class: "flex gap-1 md:gap-2") do
        div(class: "text-[10px] md:text-lg font-bold") do
          span(class: "text-primary") { "3." }
        end
        div(class: "flex flex-col gap-1") do
          span(class: "text-[8px] md:text-lg font-bold") { "자동으로 텍스트를 추출 합니다." }
          span(class: "text-base-content/50 text-[5px] md:text-[10px]") { "텍스트를 추출하고 태그를 달아 찾기쉽게 분류하세요!" }
        end
      end
      div(class: "bg-primary rounded-3xl flex items-center justify-center gap-1 p-1 md:p-3 md:h-[50px]") do
        span(class: "text-[5px] md:text-base") { "시작 해보기" }
        raw(<<~SVG.html_safe)
          <svg class="h-[8px] md:h-[20px]" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
            <path stroke-linecap="round" stroke-linejoin="round" d="m8.25 4.5 7.5 7.5-7.5 7.5" />
          </svg>
        SVG
      end
    end
  end
end
