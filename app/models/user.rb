class User < ApplicationRecord
  include BaseActionable

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

  # USECASE: 사용자 데이터 초기화
  def reset_user_data!
    transaction do
      # OTP 초기화
      update!(otp: nil, otp_expiry_date: nil)

      # 게시물 삭제
      posts.destroy_all if posts.exists?

      # 즐겨찾기 삭제
      favorites.destroy_all if favorites.exists?

      # 즐겨찾기 카테고리 삭제
      favorite_categories.destroy_all if favorite_categories.exists?

      # 일반 사진첩 삭제
      collections.where(type: "DEFAULT").destroy_all
    end

    true
  end

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
