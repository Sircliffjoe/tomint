# frozen_string_literal: true

class Users::PasswordsController < Devise::PasswordsController
  layout "public"

  def new
    self.resource = resource_class.new
  end

  def create
    self.resource = resource_class.find_by(email: password_params[:email].to_s.strip.downcase)

    if resource && update_password(resource)
      redirect_to new_user_session_path, notice: "Your password has been changed. Please sign in with the new password."
    else
      self.resource ||= resource_class.new(email: password_params[:email])
      resource.errors.add(:base, "We could not update your password. Check your email and password confirmation.") if resource.errors.blank?
      render :new, status: :unprocessable_entity
    end
  end

  # GET /resource/password/edit?reset_password_token=abcdef
  # def edit
  #   super
  # end

  # PUT /resource/password
  # def update
  #   super
  # end

  # protected

  # def after_resetting_password_path_for(resource)
  #   super(resource)
  # end

  # The path used after sending reset password instructions
  # def after_sending_reset_password_instructions_path_for(resource_name)
  #   super(resource_name)
  # end

  private

  def password_params
    params.require(resource_name).permit(:email, :password, :password_confirmation)
  end

  def update_password(user)
    user.password = password_params[:password]
    user.password_confirmation = password_params[:password_confirmation]
    user.mark_password_changed!
    user.save
  end
end
