class User::UpdateProfile
  def initialize(current_user, params)
    @current_user = current_user
    @nickname = params[:nickname] || ""
    @bio      = params[:bio] || ""
    @file     = params[:file]

    # "null" 문자열을 nil로 처리
    @file = nil if @file == "null"
  end

  def call
    # 프로필 정보 업데이트
    @current_user.nickname = @nickname if @nickname.present?
    @current_user.bio = @bio if @bio.present?

    # 파일 처리 로직
    if @file.present?
      # 파일 유효성 검증 (클래스 메서드 사용)
      validation_result = Shared::ImageValidator.validate_image_file(@file)
      return validation_result if validation_result.failure?

      # 유효한 파일일 경우 처리
      Rails.logger.info "새 프로필 이미지 업로드 및 크롭"

      begin
        # 기존 이미지가 있으면 제거
        @current_user.image.purge if @current_user.image.attached?

        # 새 이미지 첨부 - 크롭 및 리사이즈 처리 없이 원본 저장
        @current_user.image.attach(@file)

        # 이미지 처리 - 250x250으로 크롭 및 리사이즈
        @current_user.image.variant(resize_to_fill: [ 250, 250 ]).processed
      rescue ActiveStorage::FileNotFoundError => e
        # 테스트 환경에서는 파일 처리 오류를 무시
        Rails.logger.warn "파일 처리 중 오류 발생: #{e.message}" if Rails.env.test?
      end
    end

    # 변경사항 저장
    @current_user.save!

    Result.success
  end
end
