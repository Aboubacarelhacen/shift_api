class ShiftAssignmentSerializer < ActiveModel::Serializer
  attributes :id, :shift_id, :employee_id, :created_by_user_id, :created_at
  belongs_to :employee
end
