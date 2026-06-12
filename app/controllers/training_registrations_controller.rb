class TrainingRegistrationsController < ApplicationController
  layout "public"
  before_action :set_training

  def create
    @registration = @training.training_registrations.build(training_registration_params)
    @registration.user = current_user if user_signed_in?

    if @registration.save
      redirect_to training_path(@training), notice: "Thank you for registering for #{@training.title}."
    else
      @training_registration = @registration
      render "trainings/show", status: :unprocessable_entity
    end
  end

  private

  def set_training
    @training = Training.find(params[:training_id])
  end

  def training_registration_params
    params.require(:training_registration).permit(:guest_name, :guest_email, :guest_phone)
  end
end
