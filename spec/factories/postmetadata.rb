FactoryBot.define do
  factory :post_metadatum do
    content { "메타데이터 내용" }
    is_public { true }
    has_link { false }
    association :post

    trait :private do
      is_public { false }
    end

    trait :with_link do
      has_link { true }
    end

    trait :short_content do
      content { "A" }
    end

    trait :long_content do
      content { "A" * 31 }
    end
  end
end
