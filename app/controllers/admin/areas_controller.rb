module Admin
  class AreasController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_admin!
    before_action :set_state
    before_action :set_area, only: %i[ edit update destroy ]

    def index
      @areas = @state.areas.order(:name).includes(:area_leader)
    end

    def new
      @area = @state.areas.new
    end

    def edit
    end

    def create
      @area = @state.areas.new(area_params)

      if @area.save
        redirect_to admin_state_areas_path(@state), notice: "Area was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @area.update(area_params)
        redirect_to admin_state_areas_path(@state), notice: "Area was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @area.destroy
      redirect_to admin_state_areas_path(@state), notice: "Area was successfully deleted."
    end

    private

    def set_state
      @state = State.find(params[:state_id])
    end

    def set_area
      @area = @state.areas.find(params[:id])
    end

    def area_params
      params.require(:area).permit(:name, :description, :area_leader_id)
    end

    def authorize_admin!
      redirect_to root_path, alert: "Not authorized." unless current_user.super_admin? || current_user.state_admin?
    end
  end
end
