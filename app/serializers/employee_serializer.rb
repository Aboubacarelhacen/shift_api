class EmployeeSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :full_name, :email, :phone, :team, :role, :active, :user_id

  def full_name
    object.full_name
  end
end
