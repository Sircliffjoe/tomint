class Donation < ApplicationRecord
  enum :status, {
    pending: 0,
    successful: 1,
    failed: 2
  }, default: :pending

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :donor_email, presence: true
end
