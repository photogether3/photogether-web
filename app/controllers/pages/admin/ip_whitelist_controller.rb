class Pages::Admin::IpWhitelistController < Pages::AdminController
  def index
    render Pages::Admin::IpWhitelist::Index.new
  end

  def new
    alert = flash[:alert] || nil
    ip_whitelist_params = flash[:ip_whitelist] || {}
    ip_whitelist = IpWhitelist.new(ip_whitelist_params)
    puts ip_whitelist.inspect
    render Pages::Admin::IpWhitelist::New.new(ip_whitelist: ip_whitelist, alert: alert)
  end

  def create
    result = Admin::IpWhitelist::Create.new(ip_whitelist_params).call
    if result.success?
      redirect_to admin_ip_whitelist_path, notice: "성공적으로 등록되었습니다.", status: :see_other
    else
      flash[:alert] = result.error_message
      flash[:ip_whitelist] = ip_whitelist_params.to_h
      redirect_to admin_ip_whitelist_new_path
    end
  end

  private

  def ip_whitelist_params
    params.require(:ip_whitelist).permit(:ip, :description)
  end
end
