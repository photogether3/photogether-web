class Policy < ApplicationRecord
  has_many :policy_acceptances, dependent: :destroy
  has_many :users, through: :policy_acceptances

  validates :title, :kind, :content, :version, :effective_date, presence: true
  validates :version, uniqueness: { scope: :kind }

  scope :active, -> { where(is_active: true) }
  scope :by_kind, ->(kind) { where(kind: kind) }

  def self.latest_of_kind(kind)
    by_kind(kind).active.order(version: :desc).first
  end
end
