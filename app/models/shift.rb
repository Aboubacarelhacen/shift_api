class Shift < ApplicationRecord
	has_many :shift_assignments, dependent: :destroy
	has_many :employees, through: :shift_assignments

	validates :title, :date, :starts_at, :ends_at, :capacity, presence: true
	validates :capacity, numericality: { greater_than_or_equal_to: 1 }
	validate :start_before_end

	def full?
		shift_assignments.count >= capacity.to_i
	end

	private

	def start_before_end
		return if starts_at.blank? || ends_at.blank?
		errors.add(:ends_at, 'must be after starts_at') if ends_at <= starts_at
	end
end
