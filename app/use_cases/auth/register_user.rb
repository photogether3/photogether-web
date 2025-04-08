class Auth::RegisterUser < BaseUseCase
  def initialize(params, options = {})
    @email     = params[:email] || ""
    @password  = params[:password] || ""
    @with_user = options.fetch(:with_user, false) # 프로세스가 끝날 때 user 데이터를 반환할지 여부
  end

  def call
    return failure("유효한 이메일을 입력해 주세요.") unless valid_email?
    return failure("비밀번호를 입력해 주세요.") if @password.blank?

    ActiveRecord::Base.transaction do
      user = User.create!(
        email_address: @email,
        password: @password,
        password_confirmation: @password,
        role_id: 1,
        nickname: generate_random_nickname,
      )

      user.collections.create!([
        { category_id: nil, type: "UNCATEGORIZED", title: "미분류" },
        { category_id: nil, type: "TRASH", title: "휴지통" }
      ])

      puts "회원가입 성공: #{user.inspect}"

      success(user)
    end
  end

  private

    # 이메일 유효성 검증
    def valid_email?
      @email.match?(User::EMAIL_REGEX)
    end

    # 랜덤한 닉네임을 생성하는 메서드
    def generate_random_nickname
      prefixes = %w[
        멋진 든든한 귀여운 강력한 재빠른
        화려한 용감한 현명한 활기찬 유쾌한
      ]

      suffixes = %w[
        고래밥 사자 호랑이 독수리 고양이
        강아지 여우 팬더 토끼 공룡
      ]

      random_prefix = prefixes.sample
      random_suffix = suffixes.sample

      "#{random_prefix} #{random_suffix}"
    end
end
