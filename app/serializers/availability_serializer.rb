class AvailabilitySerializer < ActiveModel::Serializer
  attributes :id, :weekday, :start_time, :end_time
end
