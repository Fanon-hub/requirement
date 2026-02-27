FactoryBot.define do
  factory :user do
    name { "Test User" }
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }

    trait :admin do
      role { 'admin' }
      admin { true }
    end

    trait :guest do
      guest { true }
    end
  end
end