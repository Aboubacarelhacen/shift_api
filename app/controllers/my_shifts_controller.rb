class MyShiftsController < ApplicationController
  before_action :authenticate_user!

  def index
    employee = current_user.employee
    return render json: { data: [] } unless employee

  assignments = ShiftAssignment.joins(:shift).where(employee_id: employee.id).order('shifts.date ASC')
    data = assignments.map do |a|
      s = a.shift
      {
        id: s.id,
        title: s.title,
        date: s.date,
        starts_at: s.starts_at,
        ends_at: s.ends_at,
        location: s.location,
        role_required: s.role_required,
        notes: s.notes
      }
    end
    render json: { data: data }
  end
end
