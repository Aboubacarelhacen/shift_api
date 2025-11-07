class SwapRequest < ApplicationRecord
  belongs_to :shift
  belongs_to :from_employee, class_name: 'Employee'
  belongs_to :to_employee, class_name: 'Employee'
  belongs_to :created_by_user, class_name: 'User', optional: true
  belongs_to :decision_by_user, class_name: 'User', optional: true

  enum :status, { pending: 0, accepted: 1, rejected: 2, cancelled: 3 }, prefix: true, default: :pending

  validates :reason, presence: true
  validate :from_employee_assigned_to_shift

  def from_employee_assigned_to_shift
    return if shift.blank? || from_employee.blank?
    assigned = shift.shift_assignments.exists?(employee_id: from_employee_id)
    errors.add(:from_employee_id, 'is not assigned to shift') unless assigned
  end
end
