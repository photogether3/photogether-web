class User < ApplicationRecord
  include Rails.application.routes.url_helpers

  # ------------------------------------------------------
  # 관계 설정
  # ------------------------------------------------------
  belongs_to :role
  has_secure_password validations: false
  has_one_attached :image
  has_one :refresh_token, dependent: :destroy
  has_many :sessions, dependent: :destroy
  has_many :collections, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :favorite_categories, through: :favorites, source: :category
  has_many :posts, dependent: :destroy

  # ------------------------------------------------------
  # 유효성 검사 (이메일, 비밀번호, 닉네임)
  # ------------------------------------------------------
  validates :email_address,
            presence: { message: "이메일 주소를 입력해주세요." },
            uniqueness: { message: "이미 사용 중인 이메일 주소입니다." },
            format: { with: ValidationPatterns::EMAIL_REGEX, message: "유효한 이메일 형식이 아닙니다." }
  validates :password,
            presence: {
              message: "비밀번호를 입력해주세요.",
              if: -> { new_record? }
            },
            format: {
              with: ValidationPatterns::PASSWORD_REGEX,
              message: "비밀번호는 8-50자 사이이며, 소문자, 숫자, 특수문자를 각각 하나 이상 포함해야 합니다.",
              if: -> { password.present? }
            }
  validates :nickname,
            format: {
              with: ValidationPatterns::NICKNAME_REGEX,
              message: "닉네임은 2~20자 사이의 영문, 숫자, 한글만 허용됩니다.",
              allow_blank: true
            }

  # ------------------------------------------------------
  # OTP 유효성 검증
  # ------------------------------------------------------
  def verify_otp(otp)
    puts "OTP_EXPIRY_DATE: #{self.otp_expiry_date}"
    puts "OTP: #{self.otp}"
    is_valid = self.otp == otp && self.otp_expiry_date > Time.now
    is_valid
  end

  # ------------------------------------------------------
  # OTP 새로 발급: 6자리 OTP 생성 및 만료일 5분 후로 설정
  # ------------------------------------------------------
  def update_otp(otp)
    self.update!(
      otp: otp,
      otp_expiry_date: 5.minutes.from_now
    )
  end

  # ------------------------------------------------------
  # OTP 초기화: OTP와 만료일을 nil로 설정하고 추가 업데이트 허용
  # ------------------------------------------------------
  def reset_otp
    transaction do
      self.otp = nil
      self.otp_expiry_date = nil

      yield(self) if block_given?

      self.save!
    end
  end

  # ------------------------------------------------------
  # JSON 형식 반환
  # ------------------------------------------------------
  def to_detail(options = {})
    result = {
      id: id,
      nickname: nickname,
      bio: bio,
      created_at: created_at,
      updated_at: updated_at,
      email: email_address
    }

    # 이미지 URL 추가
    result[:image_url] = image.attached? ? Rails.application.routes.url_helpers.url_for(image) : nil

    # 추가 옵션 병합
    result.merge!(options)

    result
  end
end
