class ShiftAssignment < ApplicationRecord
  belongs_to :shift
  belongs_to :employee
  belongs_to :created_by_user, class_name: 'User', optional: true

  validates :employee_id, uniqueness: { scope: :shift_id }
  validate :no_overlap

  def no_overlap
    return if shift.blank? || employee.blank?
    overlapping = Shift.joins(:shift_assignments)
                        .where(shift_assignments: { employee_id: employee.id })
                        .where.not(id: shift.id)
                        .where('starts_at < ? AND ends_at > ?', shift.ends_at, shift.starts_at)
    errors.add(:base, 'Employee has overlapping assignment') if overlapping.exists?
  end
end
