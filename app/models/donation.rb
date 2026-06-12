class Donation < ApplicationRecord
  before_validation :set_default_currency

  enum :status, {
    pending: 0,
    successful: 1,
    failed: 2
  }, default: :pending

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :donor_email, presence: true

  def display_currency
    currency.presence || "NGN"
  end

  private

  def set_default_currency
    self.currency = display_currency
  end
end
