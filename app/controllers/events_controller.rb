class EventsController < ApplicationController
  layout "public"

  def index
    @events = policy_scope(Event).where("start_time IS NULL OR start_time >= ?", Time.current).order(Arel.sql("start_time IS NULL, start_time ASC"))
    @past_events = policy_scope(Event).where("start_time < ?", Time.current).order(start_time: :desc).limit(5)
  end

  def show
    @event = Event.find(params[:id])
    @registration = Registration.new
    if user_signed_in?
      @existing_registration = Registration.find_by(user: current_user, event: @event)
      @registration.guest_name = current_user.full_name
      @registration.guest_email = current_user.email
    end
  end
end
