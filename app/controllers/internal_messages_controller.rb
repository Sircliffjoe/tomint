class InternalMessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_messaging_user!
  before_action :set_message, only: :show
  before_action :set_recipients, only: %i[ new create ]

  def index
    @inbox_messages = current_user.received_internal_messages.includes(:sender).recent
    @sent_messages = current_user.sent_internal_messages.includes(:recipient).recent
    @unread_count = current_user.received_internal_messages.unread.count
  end

  def show
    @message.mark_read! if @message.recipient == current_user
  end

  def new
    @message = current_user.sent_internal_messages.build(prefill_params)
  end

  def create
    @message = current_user.sent_internal_messages.build(message_params)

    if @message.save
      redirect_to internal_messages_path, notice: "Message sent."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_message
    @message = InternalMessage
      .where("sender_id = :user_id OR recipient_id = :user_id", user_id: current_user.id)
      .find(params[:id])
  end

  def set_recipients
    @recipients = User
      .where.not(id: current_user.id)
      .where.not(role: :super_admin)
      .order(:first_name, :last_name)
  end

  def message_params
    params.require(:internal_message).permit(:recipient_id, :subject, :body)
  end

  def prefill_params
    params.fetch(:internal_message, {}).permit(:recipient_id, :subject)
  end

  def authorize_messaging_user!
    redirect_to dashboard_path, alert: "Messaging is not available for Super Admin." if current_user.super_admin?
  end
end
