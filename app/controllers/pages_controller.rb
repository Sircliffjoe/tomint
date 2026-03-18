class PagesController < ApplicationController
  layout "public"
  def about
  end

  def show
    @page = Page.find_by!(slug: params[:slug])
  rescue ActiveRecord::RecordNotFound
    raise ActionController::RoutingError.new("Not Found")
  end
end
