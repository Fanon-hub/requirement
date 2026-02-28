FactoryBot.define do
  factory :notification do
    user { association :user }
    notification_type { 'info' }
    message { 'Test notification' }
    is_read { false }
  end
end
