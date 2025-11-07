FactoryBot.define do
  factory :swap_request do
    association :shift
    association :from_employee, factory: :employee
    association :to_employee, factory: :employee
    status { :pending }
    reason { 'Need to swap' }
    association :created_by_user, factory: :user
  end
end
