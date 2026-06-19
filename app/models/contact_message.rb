require "uri"

class ContactMessage < ApplicationRecord
  SUBJECTS = [
    "General enquiry",
    "Events",
    "Training",
    "Donation"
  ].freeze

  validates :name, :email, :subject, :message, presence: true
  validates :subject, inclusion: { in: SUBJECTS }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }

  scope :recent, -> { order(created_at: :desc) }
  scope :unread, -> { where(read_at: nil) }

  def read?
    read_at.present?
  end

  def mark_read!
    update!(read_at: Time.current) unless read?
  end
end
