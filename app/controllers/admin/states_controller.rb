module Admin
  class StatesController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_admin!
    before_action :set_state, only: %i[ show edit update destroy ]

    def index
      @states = State.all.order(:name)
    end

    def show
    end

    def new
      @state = State.new
    end

    def edit
    end

    def create
      @state = State.new(state_params)

      if @state.save
        redirect_to admin_states_path, notice: "State was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @state.update(state_params)
        redirect_to admin_states_path, notice: "State was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @state.destroy
      redirect_to admin_states_path, notice: "State was successfully destroyed."
    end

    private

    def set_state
      @state = State.find(params[:id])
    end

    def state_params
      params.require(:state).permit(:name, :code, :zone_id, :year_created, :description, :status)
    end

    def authorize_admin!
      redirect_to root_path, alert: "Not authorized." unless current_user.super_admin?
    end
  end
end
