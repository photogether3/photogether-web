class User < ApplicationRecord
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :collections, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address,
    presence: true,
    uniqueness: true,
    length: { maximum: 50 },
    format: { with: VALID_EMAIL_REGEX }
  validates :password, presence: true, length: { minimum: 8 }, if: -> { password.present? }

  def self.register(params)
    transaction do
      user = create!(
        email_address: params[:email],
        password: params[:password],
        role_id: 1,
        nickname: generate_random_nickname
      )

      # 기본으로 생성될 Collection 예시
      user.collections.create!([
        { category_id: nil, type: "UNCATEGORIZED", title: "미분류" },
        { category_id: nil, type: "TRASH",        title: "휴지통" }
      ])

      user
    end
  end

  def self.generateOtp(params)
    user = User.find_by(email_address: params[:email])
    raise ActiveRecord::RecordNotFound, "User not found" unless user
    user.update!(otp: generate_otp, otp_expiry_date: 5.minutes.from_now)
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
