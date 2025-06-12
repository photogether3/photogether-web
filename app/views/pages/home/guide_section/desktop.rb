# 데스크탑용 뷰
class Views::Pages::Home::GuideSection::Desktop < Views::Base
  def view_template
    div(data: {
          controller: "mobile-guide",
          "mobile-guide-current-step-value": 1,
          "mobile-guide-total-steps-value": 4,
          "mobile-guide-platform": "desktop"
        },
        class: "hidden sm:flex w-[1104px] gap-[80px] items-end") do
      div(data: { "mobile-guide-target": "stepBoxContainer" },
          class: "w-[700px] h-[464px] flex flex-wrap gap-[25px]") do
        div(class: "w-[323px]")
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
        div(class: "w-[323px]")
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

      render Views::Pages::Home::GuideSection::MobileFrame.new
    end
  end
end
