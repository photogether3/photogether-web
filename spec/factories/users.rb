FactoryBot.define do
  factory :user do
    email_address { Faker::Internet.email }
    nickname { Faker::Internet.username(specifier: 5..10) }
    password { 'Password123!' }
    association :role
  end
end
