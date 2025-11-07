class TeamsController < ApplicationController
  before_action :authenticate_user!

  def index
    # Derive teams from employee.team values
    teams = Employee.where.not(team: [nil, '']).group(:team).count
    render json: teams.map { |name, count| { name: name, members: count } }
  end
end
