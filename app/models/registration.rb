class Registration < ApplicationRecord
  belongs_to :user
  belongs_to :event

  enum :status, {
    pending: 3, # New status for paid events
    confirmed: 0,
    attended: 1,
    cancelled: 2
  }, default: :confirmed

  validates :qr_code_token, uniqueness: true, allow_nil: true

  before_create :generate_qr_code_token

  private

  def generate_qr_code_token
    self.qr_code_token = SecureRandom.hex(10) if qr_code_token.blank?
  end
end
