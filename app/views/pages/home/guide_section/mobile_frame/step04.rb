class Views::Pages::Home::GuideSection::MobileFrame::Step04 < Views::Base
  def view_template
    turbo_frame(id: "mobile_frame_step") do
      img(src: "/images/landing/section02/item08.png")
    end
  end
end
