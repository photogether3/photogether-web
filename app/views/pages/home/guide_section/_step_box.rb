class Views::Pages::Home::GuideSection::StepBox < Views::Base
  def initialize(
    title: "스크린샷을 찍어주세요",
    step: 1,
    content: "지금 화면을 캡처하거나, 이미 앨범에 저장된 스크린샷을 불러와도 괜찮아요."
  )
    @title = title
    @step = step
    @content = content
  end

  def view_template
    div(data: {
          step: @step,
          action: "click->mobile-guide#onClickStep"
        },
        class: "step-box flex flex-col gap-1 border border-primary bg-base-300 rounded-xl
        p-2 w-[150px] lg:w-[323px] lg:p-[24px] lg:gap-3 cursor-pointer") do
      div(class: "flex justify-between items-center") do
        p(data: { id: "title" },
          class: "text-[10px] lg:text-xl font-bold") { @title }
        div(data: { id: "step" },
            class: "flex items-center justify-center rounded-full bg-secondary text-secondary-content border border-primary
          text-[9px] w-[20px] h-[20px] lg:text-base lg:min-w-[36px] lg:min-h-[36px]") do
          "0#{@step}"
        end
      end
      p(data: { id: "content" }, class: "text-[10px] lg:text-xs text-[#C6C6C6]") { @content }
    end
  end
end
