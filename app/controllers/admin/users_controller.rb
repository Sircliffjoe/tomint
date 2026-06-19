module Admin
  class UsersController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_admin!
    before_action :set_user, only: %i[ show edit update destroy reset_password ]

    def index
      @role = params[:role]
      @users = if @role.present?
                 User.where(role: @role).order(:first_name)
      else
                 User.where.not(role: :super_admin).order(created_at: :desc)
      end
    end

    def show
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
      generated_password = User.generate_temporary_password
      @user.password = generated_password
      @user.password_confirmation = generated_password
      @user.must_change_password = true

      if @user.save
        flash[:generated_password] = generated_password
        redirect_to admin_user_path(@user), notice: "User was successfully created. Copy the temporary password below before leaving this page."
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

    def reset_password
      generated_password = User.generate_temporary_password
      @user.password = generated_password
      @user.password_confirmation = generated_password
      @user.must_change_password = true

      if @user.save
        flash[:generated_password] = generated_password
        redirect_to admin_user_path(@user), notice: "A new temporary password was generated. Copy it before leaving this page."
      else
        redirect_to admin_user_path(@user), alert: "Could not generate a new password."
      end
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:email, :first_name, :last_name, :phone, :role, :state_id, :directorate_id, :avatar)
    end

    def user_params_no_password
      params.require(:user).permit(:email, :first_name, :last_name, :phone, :role, :state_id, :directorate_id, :avatar)
    end

    def authorize_admin!
      redirect_to root_path, alert: "Not authorized." unless current_user.super_admin?
    end
  end
end
