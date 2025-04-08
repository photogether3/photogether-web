class Auth::RegisterUser < BaseUseCase
  def initialize(email, password)
    @params = {
      email: email,
      password: password
    }
  end

  def execute
    return failure("유효한 이메일을 입력해 주세요.") unless valid_email?
    return failure("비밀번호를 입력해 주세요.") if @params[:password].blank?

    ActiveRecord::Base.transaction do
      user = User.create!(
        email_address: @params[:email],
        password: @params[:password],
        password_confirmation: @params[:password],
        role_id: 1,
        nickname: BaseUtil.generate_random_nickname,
      )

      user.collections.create!([
        { category_id: nil, type: "UNCATEGORIZED", title: "미분류" },
        { category_id: nil, type: "TRASH", title: "휴지통" }
      ])

      puts "회원가입 성공: #{user.inspect}"

      success
    end
  end

  def valid_email?
    @params[:email].match?(User::EMAIL_REGEX)
  end
end
