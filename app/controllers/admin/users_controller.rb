module Admin
  class UsersController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_admin!
    before_action :set_user, only: %i[ edit update destroy ]

    def index
      @role = params[:role]
      @users = if @role.present?
                 User.where(role: @role).order(:first_name)
      else
                 User.where.not(role: :super_admin).order(created_at: :desc)
      end
    end

    def new
      @user = User.new
      @role = params[:role] || "public_user"
      @user.role = @role
    end

    def edit
    end

    def create
      @user = User.new(user_params)
      # Set a default password if creating manually, user can reset later
      @user.password = "password123"
      @user.password_confirmation = "password123"

      if @user.save
        redirect_to admin_users_path(role: @user.role), notice: "User was successfully created with default password 'password123'."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @user.update(user_params_no_password)
        redirect_to admin_users_path(role: @user.role), notice: "User was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @user.destroy
      redirect_to admin_users_path(role: params[:role]), notice: "User was successfully removed."
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:email, :first_name, :last_name, :phone, :role, :state_id, :directorate_id)
    end

    def user_params_no_password
      params.require(:user).permit(:email, :first_name, :last_name, :phone, :role, :state_id, :directorate_id)
    end

    def authorize_admin!
      redirect_to root_path, alert: "Not authorized." unless current_user.super_admin?
    end
  end
end
