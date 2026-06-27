class EventsController < ApplicationController
  layout "public"

  def index
    all_events = policy_scope(Event).order(created_at: :desc)
    @spotlight_event = all_events.find(&:spotlight?) || all_events.first
    
    events_query = all_events
    events_query = events_query.where.not(id: @spotlight_event.id) if @spotlight_event
    
    @pagy, @events = pagy(:offset, events_query, limit: 9)
  end

  def show
    @event = Event.friendly_find(params[:id])
    @registration = Registration.new
    if user_signed_in?
      @existing_registration = Registration.find_by(user: current_user, event: @event)
      @registration.guest_name = current_user.full_name
      @registration.guest_email = current_user.email
    end
  end
end
