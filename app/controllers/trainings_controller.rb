class TrainingsController < ApplicationController
  layout "public"

  def index
    @categories = Training.distinct.pluck(:category)
    @trainings_by_category = policy_scope(Training).all.group_by(&:category)
  end

  def show
    @training = Training.find(params[:id])
    @training_registration = @training.training_registrations.build
    if user_signed_in?
      @training_registration.guest_name = current_user.full_name
      @training_registration.guest_email = current_user.email
    end
  end
end
