class Pages::HomeController < PagesController
  def index
    render Pages::Home::Index.new
  end

  # 모바일 프레임 내의 페이지 전환
  def mobile_frame_step
    step = params[:step] || "01"
    if step == "01"
      render Pages::Home::MobileFrame::Step01.new
    elsif step == "02"
      render Pages::Home::MobileFrame::Step02.new
    elsif step == "03"
      render Pages::Home::MobileFrame::Step03.new
    elsif step == "04"
      render Pages::Home::MobileFrame::Step04.new
    else
      render Pages::Home::MobileFrame::Step01.new
    end
  end
end
