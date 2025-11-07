class Availability < ApplicationRecord
  belongs_to :employee

  validates :weekday, inclusion: { in: 0..6 }
  validates :start_time, :end_time, presence: true
  validate :time_order

  private

  def time_order
    return if start_time.blank? || end_time.blank?
    errors.add(:end_time, 'must be after start time') if end_time <= start_time
  end
end
