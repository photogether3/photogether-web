# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

Role.create!([
  { name: 'User' },
  { name: 'Admin' }
])

User.create!(
  email_address: Rails.application.credentials.dig(:admin, :email),
  password: Rails.application.credentials.dig(:admin, :password),
  password_confirmation: Rails.application.credentials.dig(:admin, :password),
  role_id: 2,
  nickname: '관리자',
  bio: nil,
  otp: nil,
  otp_expiry_date: nil,
  is_email_verified: true,
  image_url: nil
)

Category.create!([
  {
    id: 1001,
    name: '기술'
  },
  {
    id: 1002,
    name: '건강 & 웰니스'
  },
  {
    id: 1003,
    name: '여행'
  },
  {
    id: 1004,
    name: '금융'
  },
  {
    id: 1005,
    name: '음식 & 요리'
  },
  {
    id: 1006,
    name: '엔터테인먼트'
  },
  {
    id: 1007,
    name: '교육'
  },
  {
    id: 1008,
    name: '스포츠'
  },
  {
    id: 1009,
    name: '비즈니스'
  },
  {
    id: 1010,
    name: '라이프스타일'
  }
])
