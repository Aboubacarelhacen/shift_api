class SwapRequestsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_swap, only: %i[show accept reject cancel]

  def index
    if fake_mode?
      swaps = fake_swaps
      render json: { data: swaps, meta: { page: 1, per: swaps.size, total_pages: 1, total_count: swaps.size } }
    else
      scope = SwapRequest.all
      scope = scope.where(status: SwapRequest.statuses[params[:status].downcase]) if params[:status].present?
      swaps = scope.order(created_at: :desc).page(params[:page]).per(params[:per] || 10)
      render json: {
        data: ActiveModelSerializers::SerializableResource.new(swaps, each_serializer: SwapRequestSerializer).as_json,
        meta: pagination_meta(swaps)
      }
    end
  end

  def show
    if fake_mode?
      render json: fake_swaps.first
    else
      render json: ActiveModelSerializers::SerializableResource.new(@swap).as_json
    end
  end

  def create
    if fake_mode?
      render json: fake_swaps.first.merge(id: (rand*1000).to_i, reason: params[:reason] || 'Fake reason'), status: :created
    else
      shift = Shift.find(params.require(:shift_id))
      to_employee = Employee.find(params.require(:to_employee_id))
      reason = params[:reason]
      from_employee = current_user.employee
      unless from_employee && shift.shift_assignments.exists?(employee_id: from_employee.id)
        return render json: { error: 'Forbidden', details: 'You are not assigned to this shift' }, status: :forbidden
      end
      swap = SwapRequest.create!(shift: shift, from_employee: from_employee, to_employee: to_employee, status: :pending, reason: reason, created_by_user_id: current_user.id)
      render json: ActiveModelSerializers::SerializableResource.new(swap).as_json, status: :created
    end
  end

  def accept
    if fake_mode?
      render json: fake_swaps.first.merge(status: 'accepted', decided_at: Time.now)
    else
      authorize_manager_or_admin!
      SwapRequestProcessor.new(swap_request: @swap, decided_by_user: current_user).accept!
      render json: ActiveModelSerializers::SerializableResource.new(@swap).as_json
    end
  end

  def reject
    if fake_mode?
      render json: fake_swaps.first.merge(status: 'rejected', decided_at: Time.now)
    else
      authorize_manager_or_admin!
      SwapRequestProcessor.new(swap_request: @swap, decided_by_user: current_user).reject!(reason: params[:reason])
      render json: ActiveModelSerializers::SerializableResource.new(@swap).as_json
    end
  end

  def cancel
    if fake_mode?
      render json: fake_swaps.first.merge(status: 'cancelled')
    else
      if @swap.created_by_user_id != current_user.id || !@swap.status_pending?
        return render json: { error: 'Forbidden' }, status: :forbidden
      end
      @swap.update!(status: :cancelled)
      render json: ActiveModelSerializers::SerializableResource.new(@swap).as_json
    end
  end

  private

  def set_swap
    @swap = SwapRequest.find(params[:id])
  end

  def authorize_manager_or_admin!
    render json: { error: 'Forbidden' }, status: :forbidden unless current_user.role_admin? || current_user.role_manager?
  end

  def pagination_meta(scope)
    {
      page: scope.current_page,
      per: scope.limit_value,
      total_pages: scope.total_pages,
      total_count: scope.total_count
    }
  end

  def fake_swaps
    [
      { id: 1, shift_id: 1, from_employee_id: 1, to_employee_id: 2, status: 'pending', reason: 'Need to attend appointment', created_by_user_id: 1, decision_by_user_id: nil, decided_at: nil, created_at: Time.now }
    ]
  end
end
