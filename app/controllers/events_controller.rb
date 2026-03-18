class EventsController < ApplicationController
  layout :determine_layout

  def determine_layout
    (user_signed_in? && admin_area?) ? "application" : "public"
  end
  def index
    @events = policy_scope(Event).where("start_time >= ?", Time.current).order(start_time: :asc)
    @past_events = policy_scope(Event).where("start_time < ?", Time.current).order(start_time: :desc).limit(5)
  end

  def show
    @event = Event.find(params[:id])
    if user_signed_in?
      @registration = Registration.find_by(user: current_user, event: @event)
    end
  end
end
