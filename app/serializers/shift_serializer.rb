class ShiftSerializer < ActiveModel::Serializer
  attributes :id, :title, :date, :starts_at, :ends_at, :location, :role_required, :notes, :capacity
  has_many :shift_assignments
end
