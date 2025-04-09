class User::Updater < BaseUseCase
  def initialize(current_user, params)
    @current_user = current_user
    @nickname = params[:nickname] || ""
    @bio      = params[:bio] || ""
    @file     = params[:file] || nil
  end

  def call
    @current_user.nickname = @nickname if @nickname.present?
    @current_user.bio      = @bio if @bio.present?

    if @file.present?
      case
      when @file.nil?, @file == "null"
        puts "파일 제거 요청으로 판단함"
        @current_user.image.purge if @current_user.image.attached?
      when @file.respond_to?(:content_type)
        puts "파일 전달 됨!"
        @current_user.image.purge if @current_user.image.attached?
        @current_user.image.attach(@file)
      else
        puts "file 형식이 유효하지 않음, 무시함"
      end
    end

    @current_user.save!

    success
  end
end
