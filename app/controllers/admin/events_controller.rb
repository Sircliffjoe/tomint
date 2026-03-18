module Admin
  class EventsController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_admin!
    before_action :set_event, only: %i[ edit update destroy ]

    def index
      @events = policy_scope(Event).order(start_time: :desc)
    end

    def new
      @event = Event.new
      authorize @event
    end

    def edit
      authorize @event
    end

    def create
      @event = Event.new(event_params)
      @event.state = current_user.state if current_user.state_admin? || current_user.state_secretary?

      authorize @event

      if @event.save
        redirect_to admin_events_path, notice: "Event was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      authorize @event
      if @event.update(event_params)
        redirect_to admin_events_path, notice: "Event was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @event
      @event.destroy
      redirect_to admin_events_path, notice: "Event was successfully destroyed."
    end

    private

    def set_event
      @event = Event.find(params[:id])
    end

    def event_params
      params.require(:event).permit(:title, :description, :start_time, :end_time, :location, :registration_open, :state_id, :price, :currency, :event_type, :image)
    end

    def authorize_admin!
      redirect_to root_path, alert: "Not authorized." unless current_user.super_admin? || current_user.state_admin? || current_user.state_secretary?
    end
  end
end
