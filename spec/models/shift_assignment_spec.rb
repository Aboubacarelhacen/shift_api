require 'rails_helper'

RSpec.describe ShiftAssignment, type: :model do
  it 'prevents overlapping assignments for the same employee' do
    user = create(:user)
    emp = create(:employee, user: user)
    shift1 = create(:shift, starts_at: Time.zone.parse('2025-01-01 09:00'), ends_at: Time.zone.parse('2025-01-01 12:00'))
    shift2 = create(:shift, starts_at: Time.zone.parse('2025-01-01 11:00'), ends_at: Time.zone.parse('2025-01-01 14:00'))

    create(:shift_assignment, shift: shift1, employee: emp, created_by_user: user)
    invalid = build(:shift_assignment, shift: shift2, employee: emp, created_by_user: user)
    expect(invalid.valid?).to be false
    expect(invalid.errors.full_messages.join).to match(/overlapping/i)
  end
end
