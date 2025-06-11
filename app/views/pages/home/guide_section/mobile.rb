# 데스크탑용 뷰
class Views::Pages::Home::GuideSection::Mobile < Views::Base
  def view_template
    div(class: "flex items-end justify-between mt-10 sm:hidden") do
      div(class: "w-[188px] relative") do
        render Views::Pages::Home::GuideSection::MobileFrame.new
      end
      div(class: "flex flex-col gap-[13px]") do
        # 스탭박스
        render Views::Pages::Home::GuideSection::StepBox.new(
          title: "스크린샷을 찍어주세요.",
          step: "01",
          content: "지금 화면을 캡처하거나, 이미 앨범에 저장된 스크린샷을 불러와도 괜찮아요.",
          active: true
        )

        # 컨트롤러 박스
        div(class: "flex gap-[13px]") do
          # 네비게이터 표시등
          div(class: "flex justify-center items-center gap-[2px] p-[13px] bg-[#2A2C34] rounded-2xl border border-white/20") do
            div(class: "bg-primary rounded-full w-[12px] h-[5px]")
            div(class: "bg-[#515867] rounded-full w-[5px] h-[5px]")
            div(class: "bg-[#515867] rounded-full w-[5px] h-[5px]")
            div(class: "bg-[#515867] rounded-full w-[5px] h-[5px]")
          end

          div(class: "flex gap-2") do
            div(class: "rounded-full border border-primary bg-secondary w-[32px] h-[32px] p-1") do
              raw(<<~SVG.html_safe)
                <svg class="text-secondary-content translate-x-[-1px]" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M15.75 19.5 8.25 12l7.5-7.5" />
                </svg>
              SVG
            end
            div(class: "rounded-full border border-primary bg-secondary w-[32px] h-[32px] p-1") do
              raw(<<~SVG.html_safe)
                <svg class="text-secondary-content translate-x-[1px]" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
                  <path stroke-linecap="round" stroke-linejoin="round" d="m8.25 4.5 7.5 7.5-7.5 7.5" />
                </svg>
              SVG
            end
          end
        end
      end
    end
  end
end
