class SwapRequestSerializer < ActiveModel::Serializer
  attributes :id, :shift_id, :from_employee_id, :to_employee_id, :status, :reason, :created_by_user_id, :decision_by_user_id, :decided_at, :created_at
  belongs_to :shift
  belongs_to :from_employee, class_name: 'Employee'
  belongs_to :to_employee, class_name: 'Employee'
end
