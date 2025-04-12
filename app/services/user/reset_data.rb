class User::ResetData < BaseService
  def initialize(current_user, params)
    @current_user = current_user
    @otp = params[:otp]
  end

  def call
    # OTP 유효성 검증
    return failure("OTP는 6자리 숫자여야 합니다.") unless valid_otp_format?
    return failure("로그인이 필요합니다.") unless @current_user

    # OTP 검증
    unless @current_user.verify_otp(@otp)
      return failure("OTP가 유효하지 않습니다.")
    end

    # 데이터 초기화 실행
    reset_user_data
  end

  private

  def valid_otp_format?
    @otp.to_s.match?(ValidationPatterns::OTP_REGEX)
  end

  def reset_user_data
    ActiveRecord::Base.transaction do
      # OTP 초기화
      @current_user.update!(otp: nil, otp_expiry_date: nil)

      # 게시물 삭제
      @current_user.posts.destroy_all if @current_user.posts.exists?

      # 즐겨찾기 삭제
      @current_user.favorites.destroy_all if @current_user.favorites.exists?

      # 즐겨찾기 카테고리 삭제
      @current_user.favorite_categories.destroy_all if @current_user.favorite_categories.exists?

      # 일반 사진첩 삭제 (미분류, 휴지통 제외)
      @current_user.collections.where(type: "DEFAULT").destroy_all

      success(message: "데이터가 초기화되었습니다.")
    rescue => e
      failure("데이터 초기화 중 오류가 발생했습니다: #{e.message}")
    end
  end
end
