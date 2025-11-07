FactoryBot.define do
  factory :shift_assignment do
    association :shift
    association :employee
    association :created_by_user, factory: :user
  end
end
