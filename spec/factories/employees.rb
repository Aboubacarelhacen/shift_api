FactoryBot.define do
  factory :employee do
    association :user
    sequence(:first_name) { |n| "Emp#{n}" }
    last_name { 'User' }
    phone { '555-123-4567' }
    sequence(:email) { |n| "employee#{n}@example.com" }
    team { 'Kitchen' }
    role { 'Cook' }
    active { true }
  end
end
