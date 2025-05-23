class Pages::Admin::IpWhitelistController < Pages::AdminController
  def index
    ip_whitelist = IpWhitelist.order(created_at: :desc)
    render Pages::Admin::IpWhitelist::Index.new(
      ip_whitelist: ip_whitelist,
    )
  end

  def new
    ip_whitelist_params = flash[:ip_whitelist] || {}
    ip_whitelist = IpWhitelist.new(ip_whitelist_params)
    puts ip_whitelist.inspect
    render Pages::Admin::IpWhitelist::New.new(ip_whitelist: ip_whitelist)
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

  def destroy
    ip_item = IpWhitelist.find(params[:id])
    return redirect_to admin_ip_whitelist_path, alert: "약관을 찾을 수 없습니다.", status: :see_other unless ip_item.present?

    if ip_item.destroy
      redirect_to admin_ip_whitelist_path, notice: "약관이 성공적으로 삭제되었습니다.", status: :see_other
    else
      redirect_to admin_ip_whitelist_path, alert: "약관 삭제에 실패했습니다.", status: :see_other
    end
  end

  private

  def ip_whitelist_params
    params.require(:ip_whitelist).permit(:ip, :description)
  end
end
