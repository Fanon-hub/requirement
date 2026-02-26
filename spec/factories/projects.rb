FactoryBot.define do
  factory :project do
    name { "MyString" }
    description { "MyText" }
    status { :in_progress }
    association :project_manager, factory: :user

  end
end
