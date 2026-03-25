module States
  class AreasController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_state_admin!
    before_action :set_state
    before_action :set_area, only: %i[ show edit update destroy ]

    def index
      @areas = @state.areas.order(:name).includes(:area_leader)
    end

    def show
    end

    def new
      @area = @state.areas.new
    end

    def edit
    end

    def create
      @area = @state.areas.new(area_params)

      if @area.save
        redirect_to states_state_areas_path, notice: "Area was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @area.update(area_params)
        redirect_to states_state_areas_path, notice: "Area was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @area.destroy
      redirect_to states_state_areas_path, notice: "Area was successfully deleted."
    end

    private

    def set_state
      @state = current_user.state
      unless @state
        redirect_to root_path, alert: "No state assigned to your account."
      end
    end

    def set_area
      @area = @state.areas.find(params[:id])
    end

    def area_params
      params.require(:area).permit(:name, :description, :area_leader_id)
    end

    def authorize_state_admin!
      redirect_to root_path, alert: "Not authorized." unless current_user.state_admin? || current_user.state_secretary?
    end
  end
end
