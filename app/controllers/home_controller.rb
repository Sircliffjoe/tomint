class HomeController < ApplicationController
  layout "public"
  def index
    @upcoming_events = Event.where("start_time >= ?", Time.current).order(start_time: :asc).limit(3)
  end

  def about
  end

  def contact
  end
end
