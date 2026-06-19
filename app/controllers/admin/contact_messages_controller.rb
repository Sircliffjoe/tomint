module Admin
  class ContactMessagesController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_admin!
    before_action :set_contact_message, only: %i[ show destroy mark_read ]

    def index
      @contact_messages = ContactMessage.recent
      @unread_count = ContactMessage.unread.count
    end

    def show
      @contact_message.mark_read!
    end

    def destroy
      @contact_message.destroy
      redirect_to admin_contact_messages_path, notice: "Message was successfully deleted."
    end

    def mark_read
      @contact_message.mark_read!
      redirect_to admin_contact_message_path(@contact_message), notice: "Message marked as read."
    end

    private

    def set_contact_message
      @contact_message = ContactMessage.find(params[:id])
    end

    def authorize_admin!
      redirect_to root_path, alert: "Not authorized." unless current_user.super_admin?
    end
  end
end
