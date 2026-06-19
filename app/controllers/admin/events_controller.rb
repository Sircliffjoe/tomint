module Admin
  class EventsController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_admin!
    before_action :set_event, only: %i[ show edit update destroy ]

    def index
      @events = policy_scope(Event).order(start_time: :desc)
    end

    def show
      authorize @event
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
      @event.state = current_user.state if current_user.state_coordinator? || current_user.state_secretary?

      authorize @event

      if @event.save
        redirect_to after_save_path(@event), notice: "Event was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      authorize @event
      if @event.update(event_params)
        redirect_to after_save_path(@event), notice: "Event was successfully updated."
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
      @event = Event.friendly_find(params[:id])
    end

    def event_params
      permitted = params.require(:event).permit(
        :title,
        :description,
        :start_time,
        :end_time,
        :location,
        :state_id,
        :price,
        :currency,
        :event_type,
        :image,
        :spotlight,
        camp_details_attributes: [
          :id,
          :state_name,
          :area_id,
          :area_row,
          :notes,
          :formatted_notes,
          :registration_link,
          :position,
          :flyer,
          :_destroy
        ]
      )

      unless camp_params?(permitted)
        permitted.delete(:camp_details_attributes)
      end

      permitted
    end

    def camp_params?(permitted)
      permitted[:event_type] == "information" && permitted[:title].to_s.match?(/\bcamp\b/i)
    end

    def after_save_path(event)
      event.camp_information_event? ? edit_admin_event_path(event) : admin_events_path
    end

    def authorize_admin!
      redirect_to root_path, alert: "Not authorized." unless current_user.super_admin? || current_user.state_coordinator? || current_user.state_secretary?
    end
  end
end
