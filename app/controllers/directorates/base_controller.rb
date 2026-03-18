module Directorates
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_director!

    private

    def ensure_director!
      unless current_user.directorate_director?
        redirect_to root_path, alert: "You are not authorized to access this area."
      end
    end
  end
end
