class PostMetadatum < ApplicationRecord
  belongs_to :post

  validates :content, presence: true, length: { in: 2..50 }
  validates :is_public, inclusion: { in: [ true, false ] }
end
