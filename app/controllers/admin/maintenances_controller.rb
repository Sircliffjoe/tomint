module Admin
  class MaintenancesController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_admin!

    def show
      @maintenance_active = SystemSetting.maintenance_mode?
      @maintenance_message = SystemSetting.maintenance_message
      @maintenance_end_time = SystemSetting.maintenance_end_time
    end

    def update
      message = params[:maintenance_message]
      end_time = params[:maintenance_end_time]

      if params[:toggle] == "enable"
        SystemSetting.enable_maintenance!(message: message, end_time: end_time)
        flash[:notice] = "Platform-wide maintenance mode has been ENABLED. Regular users and guests are now locked out."
      elsif params[:toggle] == "disable"
        SystemSetting.disable_maintenance!
        flash[:notice] = "Platform-wide maintenance mode has been DISABLED. Site access is restored."
      else
        SystemSetting.set("maintenance_message", message, description: "Maintenance mode message for users") if message.present?
        SystemSetting.set("maintenance_end_time", end_time.to_s, description: "Estimated completion time")
        flash[:notice] = "Maintenance settings updated successfully."
      end

      redirect_to admin_maintenance_path
    end

    def toggle
      if SystemSetting.maintenance_mode?
        SystemSetting.disable_maintenance!
        flash[:notice] = "Maintenance mode has been DISABLED. The site is live for all users."
      else
        SystemSetting.enable_maintenance!(
          message: params[:maintenance_message],
          end_time: params[:maintenance_end_time]
        )
        flash[:notice] = "Maintenance mode has been ENABLED. The site is temporarily locked for users and guests."
      end

      redirect_back fallback_location: admin_maintenance_path
    end

    private

    def authorize_admin!
      unless current_user&.super_admin?
        redirect_to root_path, alert: "You are not authorized to access maintenance settings."
      end
    end
  end
end
