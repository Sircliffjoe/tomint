module Admin
  class AreasController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_admin!
    before_action :set_state
    before_action :set_area, only: %i[ show ]

    def index
      @areas = @state.areas.order(:name).includes(:area_leader)
    end

    def show
    end

    private

    def set_state
      @state = State.find(params[:state_id])
    end

    def set_area
      @area = @state.areas.find(params[:id])
    end

    def authorize_admin!
      redirect_to root_path, alert: "Not authorized." unless current_user.super_admin?
    end
  end
end
