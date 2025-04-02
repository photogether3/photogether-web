FactoryBot.define do
  factory :category do
    name { "테스트" }

    trait :with_short_name do
      name { "A" }
    end

    trait :with_long_name do
      name { "A" * 21 }
    end

    trait :with_invalid_chars do
      name { "Test123" }
    end

    trait :with_korean_name do
      name { "테스트카테고리" }
    end

    trait :with_english_name do
      name { "TestCategory" }
    end

    trait :with_mixed_name do
      name { "테스트Test" }
    end
  end
end
