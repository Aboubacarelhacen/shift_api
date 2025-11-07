class ApplicationController < ActionController::API
  include ActionController::MimeResponds

  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from ActiveRecord::RecordNotFound do |e|
    render json: { error: 'Not Found', details: e.message, status: 404 }, status: :not_found
  end

  rescue_from ActiveRecord::RecordInvalid do |e|
    render json: { error: 'Validation failed', details: e.record.errors.full_messages, status: 422 }, status: :unprocessable_entity
  end

  rescue_from ActionController::ParameterMissing do |e|
    render json: { error: 'Bad Request', details: e.message, status: 400 }, status: :bad_request
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[full_name role])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[full_name role])
  end

  def authenticate_admin!
    authenticate_user!
    render json: { error: 'Forbidden' }, status: :forbidden unless current_user&.role_admin?
  end

  def authenticate_manager_or_admin!
    authenticate_user!
    allowed = current_user&.role_admin? || current_user&.role_manager?
    render json: { error: 'Forbidden' }, status: :forbidden unless allowed
  end

  # Demo helper to toggle fake data mode without breaking controllers
  def fake_mode?
    @fake_mode ||= ActiveModel::Type::Boolean.new.cast(ENV.fetch('FAKE_DATA', 'false'))
  end
end
 
