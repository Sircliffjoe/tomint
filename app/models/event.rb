class Event < ApplicationRecord
  belongs_to :state, optional: true
  has_many :registrations

  has_one_attached :image
  has_rich_text :description

  enum :event_type, { free: 0, paid: 1 }, default: :free

  validates :title, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :price, presence: true, if: :paid?
  validates :currency, presence: true, if: :paid?

  def free?
    event_type == "free"
  end

  def paid?
    event_type == "paid"
  end
end
