class User < ApplicationRecord
  include Rails.application.routes.url_helpers

  # ------------------------------------------------------
  # 관계 설정
  # ------------------------------------------------------
  belongs_to :role
  has_secure_password validations: false
  has_one_attached :image do |attachable|
    attachable.variant :profile, resize_to_fill: [ 250, 250 ]
  end
  has_one :refresh_token, dependent: :destroy
  has_many :sessions, dependent: :destroy
  has_many :collections, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :favorite_categories, through: :favorites, source: :category
  has_many :posts, dependent: :destroy
  has_many :policy_acceptances, dependent: :destroy
  has_many :accepted_policies, through: :policy_acceptances, source: :policy

  # ------------------------------------------------------
  # 유효성 검사 (비밀번호, 닉네임)
  # ------------------------------------------------------
  validates :password,
            presence: {
              message: "비밀번호를 입력해주세요.",
              if: -> { new_record? && password_required? }  # 조건 변경
            },
            format: {
              with: ValidationPatterns::PASSWORD_REGEX,
              message: "비밀번호는 8-50자 사이이며, 소문자, 숫자, 특수문자를 각각 하나 이상 포함해야 합니다.",
              if: -> { password.present? && password_required? }  # 조건 변경
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
  # 비밀번호가 필수인지 확인. 이메일 기반 로그인 계정들은 필수
  # ------------------------------------------------------
  def password_required?
    provider.blank? || provider == "email"
  end

  def to_detail(options = {})
    result = {
      id: id,
      nickname: nickname,
      bio: bio,
      created_at: created_at,
      updated_at: updated_at,
      is_email_verified: is_email_verified,
      email: email_address,
      provider: provider
    }

    # 이미지 URL 추가 - 크롭된 250x250 프로필 이미지 사용
    if image.attached?
      # variant(:profile)을 사용하여 미리 정의된 250x250 크기의 이미지 제공
      result[:image_url] = Rails.application.routes.url_helpers.url_for(image.variant(:profile))
      result[:original_image_url] = Rails.application.routes.url_helpers.url_for(image)
    else
      result[:image_url] = nil
    end

    # 추가 옵션 병합
    result.merge!(options)

    result
  end
end
