class Views::Pages::Home::MobileFrame::Step03 < Views::Base
  def view_template
    turbo_frame(id: "mobile_frame_step") do
      div(class: "border border-red-500 h-full w-full") do
        "스탭3"
      end
    end
  end
end
