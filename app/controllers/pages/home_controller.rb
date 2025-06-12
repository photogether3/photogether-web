class Pages::HomeController < PagesController
  def index
    render Pages::Home::Index.new
  end

  # 모바일 프레임 내의 페이지 전환
  def mobile_frame_step
    step = params[:step] || "1"
    if step == "1"
      render Pages::Home::GuideSection::MobileFrame::Step01.new
    elsif step == "2"
      render Pages::Home::GuideSection::MobileFrame::Step02.new
    elsif step == "3"
      render Pages::Home::GuideSection::MobileFrame::Step03.new
    elsif step == "4"
      render Pages::Home::GuideSection::MobileFrame::Step04.new
    else
      render Pages::Home::GuideSection::MobileFrame::Step01.new
    end
  end
end
