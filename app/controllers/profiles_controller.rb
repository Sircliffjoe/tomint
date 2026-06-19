class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user

  def show
  end

  def edit
  end

  def update
    if changing_password?
      update_password
    elsif @user.update(profile_params)
      redirect_to profile_path, notice: "Profile updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = current_user
  end

  def profile_params
    params.require(:user).permit(:first_name, :last_name, :avatar)
  end

  def password_params
    params.require(:user).permit(:current_password, :password, :password_confirmation)
  end

  def changing_password?
    params.dig(:user, :password).present? || params.dig(:user, :password_confirmation).present?
  end

  def update_password
    if @user.update_with_password(password_params)
      @user.mark_password_changed!
      @user.save(validate: false)
      bypass_sign_in(@user)
      redirect_to profile_path, notice: "Password changed successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end
end
