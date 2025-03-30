class User < ApplicationRecord
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  # 비밀번호 정규식: 최소 8자, 최대 50자, 소문자, 숫자, 특수문자를 각각 하나 이상 포함
  VALID_PASSWORD_REGEX = /\A(?=.*[a-z])(?=.*\d)(?=.*[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]).{8,50}\z/
  # OTP 정규식: 6자리 숫자
  VALID_OTP_REGEX = /^\d{6}$/

  belongs_to :role

  has_secure_password validations: false
  has_one_attached :image
  has_one :refresh_token, dependent: :destroy
  has_many :sessions, dependent: :destroy
  has_many :collections, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :favorite_categories, through: :favorites, source: :category
  has_many :posts, dependent: :destroy

  validate :validate_email_address
  validate :validate_password

  # Domain Rules 🧀

  def validate_email_address
    if email_address.blank?
      errors.add(:base, "이메일 주소를 입력해주세요.")
      return
    end

    if User.where.not(id: id).exists?(email_address: email_address)
      errors.add(:base, "이미 사용 중인 이메일 주소입니다.")
      return
    end

    # in 범위를 사용하여 길이 검사
    unless (6..50).include?(email_address.length)
      errors.add(:base, "이메일 주소는 6자 이상 50자 이하여야 합니다.")
      return
    end

    unless email_address.match?(VALID_EMAIL_REGEX)
      errors.add(:base, "유효한 이메일 형식이 아닙니다.")
    end
  end

  def validate_password
    if password.blank? && new_record?
      errors.add(:base, "비밀번호를 입력해주세요.")
      return
    end

    if password.present?
      unless password.match?(VALID_PASSWORD_REGEX)
        errors.add(:base, "비밀번호는 8-50자 사이이며, 소문자, 숫자, 특수문자를 각각 하나 이상 포함해야 합니다.")
      end
    end
  end

  # 사용자 생성과 기본 컬렉션 생성(Api, Admin 공통 사용)
  def self.create_with_default_collections(user_attributes)
    user = nil

    ActiveRecord::Base.transaction do
      # 사용자 생성
      user = create!(user_attributes)

      # 기본 컬렉션 생성
      user.collections.create!([
        { category_id: nil, type: "UNCATEGORIZED", title: "미분류" },
        { category_id: nil, type: "TRASH", title: "휴지통" }
      ])
    end

    user
  rescue ActiveRecord::RecordInvalid, StandardError => e
    Rails.logger.error("사용자 생성 실패: #{e.message}")
    raise e
  end

  # Utils 🍪

  def as_json(options = {})
    super(only: [ :id, :nickname, :bio, :image_url, :created_at, :updated_at ]).tap do |hash|
      # 원하는 필드명으로 재정의
      hash["email"] = self.email_address
    end
  end

  # OTP가 유효한지 확인합니다.
  def verify_otp(otp)
    puts "OTP_EXPIRY_DATE: #{self.otp_expiry_date}"
    puts "OTP: #{self.otp}"
    is_valid = self.otp == otp && self.otp_expiry_date > Time.now
    is_valid
  end
end
