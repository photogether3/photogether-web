class Views::Pages::Home::GuideSection::StepBox < Views::Base
  def initialize(
    title: "스크린샷을 찍어주세요",
    step: "01",
    content: "지금 화면을 캡처하거나, 이미 앨범에 저장된 스크린샷을 불러와도 괜찮아요.",
    active: false,
    dummy: false
  )
    @title = title
    @step = step
    @content = content
    @dummy = dummy
    @border = active ? "border-primary" : "border-[#A6A6A6]"
  end

  def view_template
    unless @dummy
      a(href: "/mobile-frame-step?step=#{@step}",
        data: {
          turbo_frame: "mobile_frame_step",
          "step-active-target": "step",
          action: "step-active#changeStep"
        },
        class: "flex flex-col gap-1 border #{@border} bg-base-300 rounded-xl
          p-2 w-[150px] lg:w-[323px] lg:p-[24px] lg:gap-3") do
        div(class: "flex justify-between items-center") do
          p(class: "text-[10px] lg:text-xl font-bold") { @title }
          div(class: "flex items-center justify-center rounded-full bg-secondary text-secondary-content border border-primary
            text-[9px] w-[20px] h-[20px] lg:text-base lg:min-w-[36px] lg:min-h-[36px]") do
            @step
          end
        end
        p(class: "text-[10px] lg:text-xs text-[#C6C6C6]") { @content }
      end
    else
      div(class: "w-[150px] lg:w-[323px]")
    end
  end
end
