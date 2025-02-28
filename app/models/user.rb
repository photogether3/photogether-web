class User < ApplicationRecord
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  has_one_attached :image
  has_secure_password
  has_one :refresh_token, dependent: :destroy
  has_many :sessions, dependent: :destroy
  has_many :collections, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address,
    presence: true,
    uniqueness: true,
    length: { maximum: 50 },
    format: { with: VALID_EMAIL_REGEX }
  validates :password, presence: true, length: { minimum: 8 }, if: -> { password.present? }

  # class methods ✨

  def self.login_usecase(email, password)
    user = self.find_by(email_address: email)

    err_msg = "아이디 또는 비밀번호를 찾을 수 없습니다."
    raise CustomError, err_msg unless user
    raise CustomError, err_msg if !user.authenticate(password)
    raise CustomError, "이메일 인증을 완료해주세요." unless user.is_email_verified

    JwtUtil.generate_tokens(user.id)
  end

  def self.register_usecase(email, password)
    transaction do
      user = self.create!(
        email_address: email,
        password: password,
        password_confirmation: password,
        role_id: 1,
        nickname: generate_random_nickname
      )

      user.collections.create!([
        { category_id: nil, type: "UNCATEGORIZED", title: "미분류" },
        { category_id: nil, type: "TRASH",        title: "휴지통" }
      ])
    end
  end

  def self.generate_otp_usecase(email)
    user = self.find_by(email_address: email)

    raise ActiveRecord::RecordNotFound, "User not found" unless user
    user.update!(otp: generate_otp, otp_expiry_date: 5.minutes.from_now)

    UserMailer.send_otp_email(user).deliver_now
  end

  def self.verify_otp_usecase(email, otp)
    user = self.find_by!(email_address: email)

    is_verify = user.verify_otp(otp)
    raise CustomError, "OTP has expired" unless is_verify

    user.update!(otp: nil, otp_expiry_date: nil, is_email_verified: true)

    tokens = JwtUtil.generate_tokens(user.id)
    RefreshToken.create_or_update_usecase(user.id, tokens[:refresh_token])

    tokens
  end

  # instance methods ✨

  def as_json(options = {})
    super(only: [ :id, :nickname, :bio, :image_url, :created_at, :updated_at ]).tap do |hash|
      # 원하는 필드명으로 재정의
      hash["email"] = self.email_address
    end
  end

  def verify_otp(otp)
    puts "OTP_EXPIRY_DATE: #{self.otp_expiry_date}"
    puts "OTP: #{self.otp}"
    is_invalid = self.otp == otp && self.otp_expiry_date > Time.now
    is_invalid
  end

  def update_usecase(nickname, bio, file)
    # 전달된 값이 있다면 업데이트합니다.
    self.nickname = nickname if nickname.present?
    self.bio      = bio if bio.present?

    if file.present?
      # 기존 이미지 교체 또는 새로 첨부
      self.image.purge if self.image.attached?
      self.image.attach(file)
    end

    self.save

    self
  end

  private

  def self.generate_random_nickname
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

  def self.generate_otp
    # 6자리 숫자 문자열 (100000~999999)
    (100_000 + rand(900_000)).to_s
  end
end
