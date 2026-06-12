class HomeController < ApplicationController
  layout "public"
  def index
    @upcoming_events = Event.where("start_time >= ?", Time.current).order(start_time: :asc).limit(3)
    @latest_posts = BlogPost.published.order(published_at: :desc).limit(3)
  end

  def search
    @query = params[:q].to_s.strip
    @upcoming_events = []
    @trainings = []

    if @query.present?
      pattern = "%#{ActiveRecord::Base.sanitize_sql_like(@query.downcase)}%"

      @upcoming_events = policy_scope(Event)
        .where("start_time >= ?", Time.current)
        .where("LOWER(title) LIKE :query OR LOWER(location) LIKE :query", query: pattern)
        .order(start_time: :asc)

      @trainings = policy_scope(Training)
        .left_outer_joins(:training_sessions)
        .where(
          "LOWER(trainings.title) LIKE :query OR LOWER(trainings.category) LIKE :query OR LOWER(trainings.description) LIKE :query OR LOWER(training_sessions.title) LIKE :query",
          query: pattern
        )
        .distinct
        .order(:title)
    end
  end

  def about
  end

  def contact
  end
end
