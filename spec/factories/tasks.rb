FactoryBot.define do
  factory :task do
    title       { "Task #{SecureRandom.hex(4)}" }
    description { "Task description" }
    status      { :in_progress }
    priority    { :medium }
    association :project
    association :creator, factory: :user
    assignee    { nil }
  end
end