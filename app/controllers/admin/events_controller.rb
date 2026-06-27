module Admin
  class EventsController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_admin!
    before_action :set_event, only: %i[ show edit update destroy deduplicate_camp_details ]

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

    def deduplicate_camp_details
      authorize @event, :update?

      removed_count = remove_duplicate_camp_details(@event)

      redirect_to edit_admin_event_path(@event), notice: "#{removed_count} duplicate camp #{'entry'.pluralize(removed_count)} removed."
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
          :state_id,
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

      permitted
    end

    def after_save_path(event)
      event.camp_information_event? ? edit_admin_event_path(event) : admin_events_path
    end

    def remove_duplicate_camp_details(event)
      removed_count = 0

      event.camp_details.includes(:rich_text_formatted_notes, flyer_attachment: :blob).group_by(&:location_key).each_value do |details|
        next if details.size < 2

        keeper = details.max_by { |detail| [ detail.completeness_score, detail.updated_at || detail.created_at, detail.id ] }
        (details - [ keeper ]).each do |duplicate|
          duplicate.destroy
          removed_count += 1
        end
      end

      removed_count
    end

    def authorize_admin!
      redirect_to root_path, alert: "Not authorized." unless current_user.super_admin? || current_user.state_coordinator? || current_user.state_secretary?
    end
  end
end
