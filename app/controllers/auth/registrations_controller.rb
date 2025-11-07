module Auth
  class RegistrationsController < Devise::RegistrationsController
    respond_to :json

    private

    def respond_with(resource, _opts = {})
      if resource.persisted?
        render json: { token: current_token, user: ActiveModelSerializers::SerializableResource.new(resource).as_json }, status: :created
      else
        render json: { error: 'Registration failed', details: resource.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def current_token
      request.env['warden-jwt_auth.token']
    end
  end
end
