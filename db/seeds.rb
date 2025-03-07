# Role 생성
Role.find_or_create_by!(name: 'User')
Role.find_or_create_by!(name: 'Admin')

# User 생성
User.find_or_create_by!(email_address: Rails.application.credentials.dig(:admin, :email)) do |user|
  user.password = Rails.application.credentials.dig(:admin, :password)
  user.password_confirmation = Rails.application.credentials.dig(:admin, :password)
  user.role_id = 2
  user.nickname = '관리자'
  user.is_email_verified = true
end

# Category 생성
categories = [
  { id: 1001, name: '기술' },
  { id: 1002, name: '건강 & 웰니스' },
  { id: 1003, name: '여행' },
  { id: 1004, name: '금융' },
  { id: 1005, name: '음식 & 요리' },
  { id: 1006, name: '엔터테인먼트' },
  { id: 1007, name: '교육' },
  { id: 1008, name: '스포츠' },
  { id: 1009, name: '비즈니스' },
  { id: 1010, name: '라이프스타일' }
]

categories.each do |category|
  Category.find_or_create_by!(id: category[:id]) do |c|
    c.name = category[:name]
  end
end
