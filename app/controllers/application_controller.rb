class ApplicationController < ActionController::Base
  include Pundit::Authorization

  def after_sign_in_path_for(resource)
    # Redirect to the smart dashboard controller
    dashboard_path
  end

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes
  helper_method :admin_area?, :dashboard_path_for_current_user

  before_action :load_global_modal_content
  before_action :enforce_password_change

  def admin_area?
    self.class.name.start_with?("Admin::", "Directorates::", "States::") ||
    %w[dashboard reports events trainings profiles internal_messages].include?(controller_name)
  end

  def dashboard_path_for_current_user
    return root_path unless user_signed_in?

    case current_user.role
    when "super_admin"
      admin_dashboard_path
    when "directorate_director"
      directorates_dashboard_path
    when "state_coordinator", "state_secretary"
      states_dashboard_path
    else
      reports_path
    end
  end

  private

  def load_global_modal_content
    return if admin_area? # Don't show modal in admin areas
    return unless controller_path == "home" && action_name == "index"

    active_announcement = Announcement.where('created_at >= ?', 7.days.ago).order(created_at: :desc).first
    spotlight_event = Event.where(spotlight: true).where('start_time IS NULL OR start_time >= ?', Time.current).order(created_at: :desc).first

    if active_announcement&.priority?
      @global_modal_item = active_announcement
    elsif spotlight_event
      @global_modal_item = spotlight_event
    elsif active_announcement
      @global_modal_item = active_announcement
    end
  end

  def enforce_password_change
    return unless user_signed_in?
    return unless current_user.must_change_password?
    return if devise_controller?
    return if controller_path == "profiles" && %w[ edit update ].include?(action_name)
    return if controller_path == "dashboard" && action_name == "index"

    redirect_to edit_profile_path, alert: "Please change your temporary password before continuing."
  end
end
