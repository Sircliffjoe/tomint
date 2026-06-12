class TrainingRegistration < ApplicationRecord
  belongs_to :training
  belongs_to :user, optional: true

  validates :guest_name, :guest_email, presence: true
  validates :guest_email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
end
