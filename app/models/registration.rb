class Registration < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :event

  enum :status, {
    pending: 3, # New status for paid events
    confirmed: 0,
    attended: 1,
    cancelled: 2
  }, default: :confirmed

  validates :qr_code_token, uniqueness: true, allow_nil: true
  validates :guest_name, :guest_email, presence: true, unless: :user_id?
  validates :guest_email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true

  before_create :generate_qr_code_token

  def attendee_name
    user&.full_name.presence || guest_name
  end

  def attendee_email
    user&.email.presence || guest_email
  end

  private

  def generate_qr_code_token
    self.qr_code_token = SecureRandom.hex(10) if qr_code_token.blank?
  end
end
