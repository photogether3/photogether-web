# 데스크탑용 뷰
class Views::Pages::Home::GuideSection::Mobile < Views::Base
  def view_template
    div(data: {
          controller: "mobile-guide",
          "mobile-guide-current-step-value": 1,
          "mobile-guide-total-steps-value": 4,
          "mobile-guide-platform-value": "mobile"
        },
        class: "flex items-end justify-between mt-10 sm:hidden") do
      div(class: "w-[188px] relative") do
        render Views::Pages::Home::GuideSection::MobileFrame.new
      end
      div(class: "flex flex-col gap-[13px]") do
        div(data: { "mobile-guide-target": "stepBoxContainer" }) do
          render Views::Pages::Home::GuideSection::StepBox.new(
            title: "스크린샷을 찍어주세요.",
            step: 1,
            content: "지금 화면을 캡처하거나, 이미 앨범에 저장된 스크린샷을 불러와도 괜찮아요.",
          )
          render Views::Pages::Home::GuideSection::StepBox.new(
            title: "업로드를 눌러주세요.",
            step: 2,
            content: "불러오고 싶은 스크린샷을 선택한 후, ‘업로드’ 버튼을 눌러 포토게더에 등록해보세요"
          )
          render Views::Pages::Home::GuideSection::StepBox.new(
            title: "텍스트를 추출 합니다.",
            step: 3,
            content: "스크린샷 안에 담긴 문구와 정보를 자동으로 분석해, 텍스트 형태로 깔끔하게 정리해드립니다."
          )
          render Views::Pages::Home::GuideSection::StepBox.new(
            title: "폴더로 정리하세요.",
            step: 4,
            content: "정리 기준은 사용자 마음대로! 폴더를 직접 선택해 필요한 대로 분류할 수 있어요."
          )
        end

        # 컨트롤러 박스
        div(class: "flex gap-[13px]") do
          # 인디게이터
          div(data: { "mobile-guide-target": "indicator" },
              class: "flex justify-center items-center gap-[2px] p-[13px] bg-[#2A2C34] rounded-2xl border border-white/20") do
            div(class: "bg-primary rounded-full w-[12px] h-[5px]")
            div(class: "bg-[#515867] rounded-full w-[5px] h-[5px]")
            div(class: "bg-[#515867] rounded-full w-[5px] h-[5px]")
            div(class: "bg-[#515867] rounded-full w-[5px] h-[5px]")
          end

          div(class: "flex gap-2") do
            # 이전 버튼
            button(data: { action: "click->mobile-guide#onPrevStep" },
                class: "rounded-full border border-primary bg-secondary w-[32px] h-[32px] p-1") do
              raw(<<~SVG.html_safe)
                <svg class="text-secondary-content translate-x-[-1px]" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M15.75 19.5 8.25 12l7.5-7.5" />
                </svg>
              SVG
            end
            # 다음 버튼
            button(data: { action: "click->mobile-guide#onNextStep" },
                class: "rounded-full border border-primary bg-secondary w-[32px] h-[32px] p-1") do
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
