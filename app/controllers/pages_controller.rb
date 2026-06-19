class PagesController < ApplicationController
  include SpamProtection

  layout "public"
  def about
  end

  def programmes
  end

  def contact
    @contact_message = ContactMessage.new
    @contact_form_started_at = form_started_at
  end

  def show
    @page = Page.find_by!(slug: params[:slug])
  rescue ActiveRecord::RecordNotFound
    raise ActionController::RoutingError.new("Not Found")
  end
end
