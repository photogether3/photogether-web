class Category < ApplicationRecord
  has_many :favorites, dependent: :destroy
  has_many :favorite_users, through: :favorites, source: :user

  validates :name, presence: { message: "카테고리 이름을 입력해주세요." }
end
