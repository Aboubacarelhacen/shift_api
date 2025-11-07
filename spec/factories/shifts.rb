FactoryBot.define do
  factory :shift do
    sequence(:title) { |n| "Shift #{n}" }
    date { Date.today }
    starts_at { Time.zone.now.change(min: 0, sec: 0) }
    ends_at { starts_at + 4.hours }
    location { 'Kitchen' }
    role_required { 'Cook' }
    notes { nil }
    capacity { 2 }
  end
end
