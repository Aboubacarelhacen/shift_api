class EmployeesController < ApplicationController
  before_action :authenticate_manager_or_admin!, only: %i[create update destroy]
  before_action :authenticate_user!, only: %i[index show availability update_availability]
  before_action :set_employee, only: %i[show update destroy availability update_availability]

  def index
    if fake_mode?
      employees = fake_employees
      render json: { data: employees, meta: { page: 1, per: employees.size, total_pages: 1, total_count: employees.size } }
    else
      q = Employee.where(active: true).ransack(params[:q])
      employees = q.result.order(id: :asc).page(params[:page]).per(params[:per] || 10)
      render json: {
        data: ActiveModelSerializers::SerializableResource.new(employees, each_serializer: EmployeeSerializer).as_json,
        meta: pagination_meta(employees)
      }
    end
  end

  def show
    if fake_mode?
      render json: { id: 1, first_name: 'Fake', last_name: 'Employee', full_name: 'Fake Employee', email: 'fake-employee@example.com', phone: '555-0000', team: 'Kitchen', role: 'Cook', active: true, user_id: 1 }
    else
      render json: ActiveModelSerializers::SerializableResource.new(@employee).as_json
    end
  end

  def create
    employee = Employee.new(employee_params)
    employee.save!
  render json: ActiveModelSerializers::SerializableResource.new(employee).as_json, status: :created
  end

  def update
    @employee.update!(employee_params)
  render json: ActiveModelSerializers::SerializableResource.new(@employee).as_json
  end

  def destroy
    @employee.update!(active: false)
    head :no_content
  end

  def availability
    avs = @employee.availabilities.order(:weekday)
  render json: ActiveModelSerializers::SerializableResource.new(avs, each_serializer: AvailabilitySerializer).as_json
  end

  def update_availability
    items = params.require(:availabilities)
    ActiveRecord::Base.transaction do
      items.each do |item|
        a = @employee.availabilities.find_or_initialize_by(weekday: item[:weekday])
        a.start_time = item[:start_time]
        a.end_time = item[:end_time]
        a.save!
      end
    end
    availability
  end

  private

  def set_employee
    @employee = Employee.find(params[:id])
  end

  def employee_params
    params.require(:employee).permit(:user_id, :first_name, :last_name, :phone, :email, :team, :role, :active)
  end

  def pagination_meta(scope)
    {
      page: scope.current_page,
      per: scope.limit_value,
      total_pages: scope.total_pages,
      total_count: scope.total_count
    }
  end

  def fake_employees
    5.times.map do |i|
      {
        id: i + 1,
        first_name: "Fake#{i+1}",
        last_name: 'User',
        full_name: "Fake#{i+1} User",
        email: "fake#{i+1}@example.com",
        phone: '555-1234',
        team: ['Kitchen','FrontDesk'].sample,
        role: ['Cook','Cashier','Runner'].sample,
        active: true,
        user_id: 1
      }
    end
  end
end
