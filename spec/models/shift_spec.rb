require 'rails_helper'

RSpec.describe Shift, type: :model do
  it 'invalid when ends_at before starts_at' do
    shift = build(:shift, starts_at: Time.zone.parse('2025-01-01 12:00'), ends_at: Time.zone.parse('2025-01-01 11:00'))
    expect(shift).not_to be_valid
    expect(shift.errors[:ends_at]).to be_present
  end

  it 'invalid when capacity < 1' do
    shift = build(:shift, capacity: 0)
    expect(shift).not_to be_valid
    expect(shift.errors[:capacity]).to be_present
  end
end
