module Auth
  class SessionsController < Devise::SessionsController
    respond_to :json

    private

    def respond_with(resource, _opts = {})
      render json: { token: current_token, user: ActiveModelSerializers::SerializableResource.new(resource).as_json }
    end

    def current_token
      request.env['warden-jwt_auth.token']
    end

    def respond_to_on_destroy
      head :no_content
    end
  end
end
