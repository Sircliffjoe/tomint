module States
  class StatesController < ApplicationController
    before_action :authenticate_user!
    before_action :set_state

    def show
    end

    private

    def set_state
      @state = current_user.state
      unless @state
        redirect_to root_path, alert: "No state assigned to your account."
      end
    end
  end
end
