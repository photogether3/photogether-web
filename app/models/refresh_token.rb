class RefreshToken < ApplicationRecord
  belongs_to :user

  validates :user_id, presence: true, uniqueness: true
  validates :refresh_token, presence: true, uniqueness: true

  def self.create_or_update_usecase(user_id, refresh_token)
    token_model = self.find_by(user_id: user_id)

    if !token_model
      create!(
        user_id: user_id,
        refresh_token: refresh_token,
        expiry_date: 7.days.from_now,
        last_refreshing_date: Time.zone.now
      )
    else
      token_model.update!(
        refresh_token: refresh_token,
        expiry_date: 7.days.from_now,
        last_refreshing_date: Time.zone.now
      )
    end
  end
end
