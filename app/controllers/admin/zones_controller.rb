module Admin
  class ZonesController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_admin!
    before_action :set_zone, only: %i[ edit update destroy ]

    def index
      @zones = Zone.all.order(:name).includes(:states)
    end

    def new
      @zone = Zone.new
    end

    def edit
    end

    def create
      @zone = Zone.new(zone_params)

      if @zone.save
        redirect_to admin_zones_path, notice: "Zone was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @zone.update(zone_params)
        redirect_to admin_zones_path, notice: "Zone was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @zone.destroy
      redirect_to admin_zones_path, notice: "Zone was successfully deleted."
    end

    private

    def set_zone
      @zone = Zone.find(params[:id])
    end

    def zone_params
      params.require(:zone).permit(:name, :description)
    end

    def authorize_admin!
      redirect_to root_path, alert: "Not authorized." unless current_user.super_admin?
    end
  end
end
