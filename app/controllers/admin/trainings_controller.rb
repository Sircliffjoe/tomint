module Admin
  class TrainingsController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_admin!
    before_action :set_training, only: %i[ show edit update destroy ]

    def index
      @trainings = policy_scope(Training).order(created_at: :desc)
    end

    def show
      @training_sessions = @training.training_sessions.order(:created_at)
    end

    def new
      @training = Training.new
      authorize @training
    end

    def edit
      authorize @training
    end

    def create
      @training = Training.new(training_params)
      @training.state = current_user.state if current_user.state_admin? || current_user.state_secretary?

      authorize @training

      if @training.save
        redirect_to admin_training_path(@training), notice: "Training was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      authorize @training
      if @training.update(training_params)
        redirect_to admin_training_path(@training), notice: "Training was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @training
      @training.destroy
      redirect_to admin_trainings_path, notice: "Training was successfully destroyed."
    end

    private

    def set_training
      @training = Training.find(params[:id])
    end

    def training_params
      params.require(:training).permit(:title, :description, :category)
    end

    def authorize_admin!
      redirect_to root_path, alert: "Not authorized." unless current_user.super_admin? || current_user.state_admin? || current_user.state_secretary?
    end
  end
end
