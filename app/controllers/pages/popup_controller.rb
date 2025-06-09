class Pages::PopupController < PagesController
  layout false

  def qr_code
    platform = params[:platform] || "ios"
    render Views::Pages::Home::QrContent.new(platform: platform)
  end

  def not_yet
    render Views::Shared::Components::NotYet.new
  end
end
