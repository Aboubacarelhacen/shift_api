class AssignmentValidator
  Result = Struct.new(:ok, :errors, keyword_init: true)

  def initialize(shift:, employee:, allow_availability_override: false)
    @shift = shift
    @employee = employee
    @allow_availability_override = allow_availability_override
  end

  def call
    errors = []

    if @shift.full?
      errors << 'Shift capacity reached'
    end

    if overlap_exists?
      errors << 'Employee has overlapping assignment'
    end

    unless @allow_availability_override
      unless available_for_shift?
        errors << 'Employee is not available for this time'
      end
    end

    Result.new(ok: errors.empty?, errors: errors)
  end

  private

  def overlap_exists?
    Shift.joins(:shift_assignments)
         .where(shift_assignments: { employee_id: @employee.id })
         .where('starts_at < ? AND ends_at > ?', @shift.ends_at, @shift.starts_at)
         .exists?
  end

  def available_for_shift?
    weekday = @shift.starts_at.wday
    start_t = @shift.starts_at.strftime('%H:%M:%S')
    end_t   = @shift.ends_at.strftime('%H:%M:%S')
    @employee.availabilities
             .where(weekday: weekday)
             .where('start_time <= ? AND end_time >= ?', start_t, end_t)
             .exists?
  end
end
