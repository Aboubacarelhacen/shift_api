module Dashboard
  class DashboardController < ApplicationController
    before_action :authenticate_manager_or_admin!

    def stats
      render json: {
        users: User.count,
        employees_active: Employee.where(active: true).count,
        shifts_this_week: Shift.where(date: Date.today.beginning_of_week..Date.today.end_of_week).count,
        pending_swaps: SwapRequest.where(status: :pending).count
      }
    end

    def activity
      # Simple recent activity feed (last 15 records from various models)
      items = []
      recent_shifts = Shift.order(updated_at: :desc).limit(5).map { |s| { type: 'shift', id: s.id, title: s.title, date: s.date, updated_at: s.updated_at } }
      recent_swaps = SwapRequest.order(updated_at: :desc).limit(5).map { |sw| { type: 'swap_request', id: sw.id, status: sw.status, shift_id: sw.shift_id, updated_at: sw.updated_at } }
      recent_employees = Employee.order(updated_at: :desc).limit(5).map { |e| { type: 'employee', id: e.id, name: e.full_name, active: e.active, updated_at: e.updated_at } }
      items.concat(recent_shifts).concat(recent_swaps).concat(recent_employees)
      items = items.sort_by { |i| i[:updated_at] }.reverse.take(15)
      render json: { data: items }
    end
  end
end
