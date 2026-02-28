FactoryBot.define do
  factory :project_member do
    user { nil }
    project { nil }
    role { 'contributor' }
  end
end
