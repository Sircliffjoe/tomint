class TrainingsController < ApplicationController
  layout :determine_layout

  def determine_layout
    (user_signed_in? && admin_area?) ? "application" : "public"
  end
  def index
    @categories = Training.distinct.pluck(:category)
    @trainings_by_category = policy_scope(Training).all.group_by(&:category)
  end

  def show
    @training = Training.find(params[:id])
  end
end
