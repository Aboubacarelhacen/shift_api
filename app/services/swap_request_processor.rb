class SwapRequestProcessor
  def initialize(swap_request:, decided_by_user:)
    @swap_request = swap_request
    @decided_by_user = decided_by_user
  end

  def accept!
    raise ActiveRecord::RecordInvalid.new(@swap_request), 'Not pending' unless @swap_request.status_pending?

    ActiveRecord::Base.transaction do
      shift = @swap_request.shift
      from_emp = @swap_request.from_employee
      to_emp = @swap_request.to_employee

      # Validate target employee can take the shift
      validator = AssignmentValidator.new(shift: shift, employee: to_emp, allow_availability_override: false)
      result = validator.call
      raise ActiveRecord::RecordInvalid.new(@swap_request), result.errors.join(', ') unless result.ok

      # Remove old assignment and add new one atomically
      old = shift.shift_assignments.find_by!(employee_id: from_emp.id)
      old.destroy!
      shift.shift_assignments.create!(employee_id: to_emp.id, created_by_user_id: @decided_by_user.id)

      @swap_request.update!(status: :accepted, decision_by_user: @decided_by_user, decided_at: Time.current)
    end
  end

  def reject!(reason: nil)
    raise ActiveRecord::RecordInvalid.new(@swap_request), 'Not pending' unless @swap_request.status_pending?
    @swap_request.update!(status: :rejected, decision_by_user: @decided_by_user, decided_at: Time.current)
  end
end
