class PolicyAcceptance < ApplicationRecord
  belongs_to :user
  belongs_to :policy

  validates :user_id, uniqueness: { scope: :policy_id }
  validates :accepted_at, presence: true

  before_validation :set_accepted_at, on: :create

  private

  def set_accepted_at
    self.accepted_at ||= Time.current
  end
end
