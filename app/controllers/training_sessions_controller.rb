class TrainingSessionsController < ApplicationController
  layout "public"
  before_action :authenticate_user!

  def show
    @training = Training.find(params[:training_id])
    @session = @training.training_sessions.find(params[:id])
  end
end
