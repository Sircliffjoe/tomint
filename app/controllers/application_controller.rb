class ApplicationController < ActionController::Base
  include Pundit::Authorization

  def after_sign_in_path_for(resource)
    # Redirect to the smart dashboard controller
    dashboard_path
  end

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes
  helper_method :admin_area?

  before_action :load_global_modal_content

  def admin_area?
    self.class.name.start_with?("Admin::", "Directorates::", "States::") ||
    %w[dashboard reports events trainings profiles].include?(controller_name)
  end

  private

  def load_global_modal_content
    return if admin_area? # Don't show modal in admin areas
    return unless controller_path == "home" && action_name == "index"

    active_announcement = Announcement.where('created_at >= ?', 7.days.ago).order(created_at: :desc).first
    spotlight_event = Event.where(spotlight: true).where('start_time >= ?', Time.current).order(created_at: :desc).first

    if active_announcement&.priority?
      @global_modal_item = active_announcement
    elsif spotlight_event
      @global_modal_item = spotlight_event
    elsif active_announcement
      @global_modal_item = active_announcement
    end
  end
end
