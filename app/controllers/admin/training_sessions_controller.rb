module Admin
  class TrainingSessionsController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_admin!
    before_action :set_training
    before_action :set_training_session, only: %i[ show edit update destroy ]

    def show
    end

    def new
      @training_session = @training.training_sessions.build
    end

    def edit
    end

    def create
      @training_session = @training.training_sessions.build(training_session_params)

      if @training_session.save
        redirect_to admin_training_path(@training), notice: "Session was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @training_session.update(training_session_params)
        redirect_to admin_training_path(@training), notice: "Session was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @training_session.destroy
      redirect_to admin_training_path(@training), notice: "Session was successfully destroyed."
    end

    private

    def set_training
      @training = Training.find(params[:training_id])
    end

    def set_training_session
      @training_session = @training.training_sessions.find(params[:id])
    end

    def training_session_params
      params.require(:training_session).permit(:title, :duration, :media_url)
    end

    def authorize_admin!
      redirect_to root_path, alert: "Not authorized." unless current_user.super_admin?
    end
  end
end
