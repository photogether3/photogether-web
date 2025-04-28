FactoryBot.define do
  factory :user do
    email_address { "test@example.com" }
    password { "password123" }
    is_email_verified { true }
  end
end
