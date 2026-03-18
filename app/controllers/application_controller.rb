class ApplicationController < ActionController::Base
  include Pundit::Authorization

  def after_sign_in_path_for(resource)
    # Redirect to the smart dashboard controller
    dashboard_path
  end

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes
  helper_method :admin_area?

  def admin_area?
    self.class.name.start_with?("Admin::", "Directorates::", "States::") ||
    %w[dashboard reports events trainings].include?(controller_name)
  end
end
