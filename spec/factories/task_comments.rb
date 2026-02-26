FactoryBot.define do
  factory :task_comment do
    content { "MyText" }
    task { nil }
    user { nil }
  end
end
