class ContactMessagesController < ApplicationController
  include SpamProtection

  layout "public"

  def create
    @contact_message = ContactMessage.new(contact_message_params)
    @contact_message.ip_address = request.remote_ip
    @contact_message.user_agent = request.user_agent

    if spam_submission?(:contact_message)
      redirect_to contact_path, notice: "Thank you. Your message has been received."
      return
    end

    if @contact_message.save
      redirect_to contact_path, notice: "Thank you. Your message has been received."
    else
      @contact_form_started_at = form_started_at
      render "pages/contact", status: :unprocessable_entity
    end
  end

  private

  def contact_message_params
    params.require(:contact_message).permit(:name, :email, :phone, :subject, :message)
  end
end
