FactoryBot.define do
  factory :user do
    email_address { Faker::Internet.email }
    password { 'Password123!' }
    association :role
  end
end
