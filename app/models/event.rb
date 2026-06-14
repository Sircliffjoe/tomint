class Event < ApplicationRecord
  belongs_to :state, optional: true
  has_many :registrations, dependent: :destroy

  has_one_attached :image
  has_rich_text :description

  enum :event_type, { free: 0, paid: 1, information: 2 }, default: :free

  before_validation :clear_pricing_for_information_events

  validates :title, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :price, presence: true, if: :paid?
  validates :currency, presence: true, if: :paid?

  def upcoming?
    start_time.present? && start_time >= Time.current
  end

  def registration_open?
    !information? && upcoming?
  end

  def free?
    event_type == "free"
  end

  def paid?
    event_type == "paid"
  end

  def information_only?
    event_type == "information"
  end

  private

  def clear_pricing_for_information_events
    return unless information?

    self.price = nil
    self.currency = nil
  end
end
