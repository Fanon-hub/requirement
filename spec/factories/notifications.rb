FactoryBot.define do
  factory :notification do
    user { nil }
    notifiable { nil }
    read { false }
  end
end
