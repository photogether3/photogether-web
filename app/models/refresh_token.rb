class RefreshToken < ApplicationRecord
  belongs_to :user

  validates :user_id, presence: true, uniqueness: true
  validates :refresh_token, presence: true, uniqueness: true

  # 리프레시 토큰이 만료되었는지 여부
  def expired?
    expiry_date.present? && expiry_date < Time.current
  end
end
