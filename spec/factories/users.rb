FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }

    trait :with_notes do
      after(:create) do |user|
        create_list(:note, 3, user: user)
      end
    end

    trait :with_many_notes do
      after(:create) do |user|
        create_list(:note, 10, user: user)
      end
    end
  end
end 