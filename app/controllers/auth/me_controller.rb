module Auth
  class MeController < ApplicationController
    before_action :authenticate_user!

    def show
      render json: { user: ActiveModelSerializers::SerializableResource.new(current_user).as_json }
    end
  end
end
