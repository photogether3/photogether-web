FactoryBot.define do
  factory :collection do
    title { "테스트 사진첩" }
    type { "DEFAULT" }
    association :user

    trait :with_category do
      association :category
    end

    trait :uncategorized do
      type { "UNCATEGORIZED" }
    end

    trait :trash do
      type { "TRASH" }
    end

    trait :with_long_title do
      title { "긴 제목 테스트 " + "A" * 10 }
    end

    trait :with_short_title do
      title { "A" }
    end
  end
end
