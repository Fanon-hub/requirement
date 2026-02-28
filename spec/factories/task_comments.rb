FactoryBot.define do
  factory :task_comment do
    comment_text { "MyText" }
    task { association :task }
    user { association :user }
  end
end
