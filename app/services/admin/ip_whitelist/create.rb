class Admin::IpWhitelist::Create
  def initialize(params)
    @ip = params[:ip]
    @description = params[:description]
  end

  def call
    return Result.failure("IP 주소를 입력해 주세요.") unless @ip.present?
    return Result.failure("간단한 설명을 입력해 주세요.") unless @description.present?

    duplicate_ip_item = IpWhitelist.find_by(ip: @ip)
    return Result.failure("이미 등록된 IP입니다.") if duplicate_ip_item.present?

    ip_whitelist = IpWhitelist.new(
      ip: @ip,
      description: @description,
    )

    if ip_whitelist.save
      Result.success(ip_whitelist)
    else
      Result.failure(ip_whitelist.errors.full_messages.join(", "))
    end
  end
end
