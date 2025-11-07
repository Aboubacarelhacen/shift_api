class ShiftsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_shift, only: %i[show update destroy create_assignment destroy_assignment]
  before_action :authenticate_manager_or_admin!, only: %i[create update destroy create_assignment destroy_assignment]

  def index
    if fake_mode?
      shifts = fake_shifts
      render json: { data: shifts, meta: { page: 1, per: shifts.size, total_pages: 1, total_count: shifts.size } }
    else
      scope = Shift.all
      if params[:date_from].present?
        scope = scope.where('date >= ?', params[:date_from])
      end
      if params[:date_to].present?
        scope = scope.where('date <= ?', params[:date_to])
      end
      scope = scope.where(location: params[:team]) if params[:team].present? # assuming team maps to location or team attribute elsewhere
      scope = scope.where(role_required: params[:role]) if params[:role].present?

      shifts = scope.order(:date, :starts_at).page(params[:page]).per(params[:per] || 10)
      render json: {
        data: ActiveModelSerializers::SerializableResource.new(shifts, each_serializer: ShiftSerializer).as_json,
        meta: pagination_meta(shifts)
      }
    end
  end

  def show
    if fake_mode?
      render json: fake_shifts.first
    else
      render json: ActiveModelSerializers::SerializableResource.new(@shift).as_json
    end
  end

  def create
    shift = Shift.create!(shift_params)
  render json: ActiveModelSerializers::SerializableResource.new(shift).as_json, status: :created
  end

  def update
    @shift.update!(shift_params)
  render json: ActiveModelSerializers::SerializableResource.new(@shift).as_json
  end

  def destroy
    @shift.destroy!
    head :no_content
  end

  def create_assignment
    if fake_mode?
      render json: { id: 1, shift_id: params[:id].to_i, employee_id: params.require(:employee_id).to_i, created_by_user_id: current_user.id, created_at: Time.now }, status: :created
    else
      employee = Employee.find(params.require(:employee_id))
      validator = AssignmentValidator.new(shift: @shift, employee: employee, allow_availability_override: ActiveModel::Type::Boolean.new.cast(params[:override]))
      result = validator.call
      unless result.ok
        return render json: { error: 'Assignment failed', details: result.errors }, status: :unprocessable_entity
      end
      assignment = @shift.shift_assignments.create!(employee: employee, created_by_user_id: current_user.id)
      render json: ActiveModelSerializers::SerializableResource.new(assignment).as_json, status: :created
    end
  end

  def destroy_assignment
    if fake_mode?
      head :no_content
    else
      employee_id = params.require(:employee_id)
      assignment = @shift.shift_assignments.find_by!(employee_id: employee_id)
      assignment.destroy!
      head :no_content
    end
  end

  private

  def set_shift
    @shift = Shift.find(params[:id])
  end

  def shift_params
    params.require(:shift).permit(:title, :date, :starts_at, :ends_at, :location, :role_required, :notes, :capacity)
  end

  def pagination_meta(scope)
    {
      page: scope.current_page,
      per: scope.limit_value,
      total_pages: scope.total_pages,
      total_count: scope.total_count
    }
  end

  def fake_shifts
    today = Date.today
    6.times.flat_map do |d|
      date = today + d.days
      [
        { id: d*3 + 1, title: 'Morning', date: date, starts_at: "#{date} 09:00:00", ends_at: "#{date} 13:00:00", location: 'Kitchen', role_required: 'Cook', notes: nil, capacity: 3 },
        { id: d*3 + 2, title: 'Afternoon', date: date, starts_at: "#{date} 13:00:00", ends_at: "#{date} 17:00:00", location: 'FrontDesk', role_required: 'Cashier', notes: nil, capacity: 2 },
        { id: d*3 + 3, title: 'Evening', date: date, starts_at: "#{date} 17:00:00", ends_at: "#{date} 21:00:00", location: 'Kitchen', role_required: 'Runner', notes: nil, capacity: 2 }
      ]
    end
  end
end
