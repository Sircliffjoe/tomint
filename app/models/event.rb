class Event < ApplicationRecord
  belongs_to :state, optional: true
  has_many :registrations, dependent: :destroy
  has_many :camp_details, -> { ordered }, dependent: :destroy

  has_one_attached :image
  has_rich_text :description

  accepts_nested_attributes_for :camp_details, allow_destroy: true, reject_if: :blank_camp_detail?

  enum :event_type, { free: 0, paid: 1, information: 2 }, default: :free

  CAMP_STATE_NAMES = [
    "Abia",
    "Adamawa",
    "Akwa Ibom",
    "Anambra",
    "Bauchi",
    "Bayelsa",
    "Benue",
    "Borno",
    "Cross River",
    "Delta",
    "Ebonyi",
    "Edo",
    "Ekiti",
    "Enugu",
    "FCT",
    "Gombe",
    "Imo",
    "Jigawa",
    "Kaduna",
    "Kano",
    "Katsina",
    "Kebbi",
    "Kogi",
    "Kwara",
    "Lagos",
    "Nasarawa",
    "Niger",
    "Ogun",
    "Ondo",
    "Osun",
    "Oyo",
    "Plateau",
    "Rivers",
    "Sokoto",
    "Taraba",
    "Yobe",
    "Zamfara"
  ].freeze

  before_validation :clear_pricing_for_information_events

  validates :title, presence: true

  def upcoming?
    start_time.blank? || start_time >= Time.current
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

  def camp_information_event?
    information_only? && title.to_s.match?(/\bcamp\b/i)
  end

  def date_label
    start_time&.strftime("%b %d, %Y") || "Date TBA"
  end

  def long_date_label
    start_time&.strftime("%A, %B %d, %Y") || "Date TBA"
  end

  def time_label
    return "Time TBA" if start_time.blank?
    return start_time.strftime("%I:%M %p") if end_time.blank?

    "#{start_time.strftime("%I:%M %p")} - #{end_time.strftime("%I:%M %p")}"
  end

  def calendar_month_label
    start_time&.strftime("%b") || "TBA"
  end

  def calendar_day_label
    start_time&.strftime("%d") || "--"
  end

  def location_label
    location.presence || state&.name || "Location TBA"
  end

  def display_price
    return "Information event" if information_only?
    return "Free event" unless paid?
    return "Price TBA" if price.blank?

    "#{currency.presence || "NGN"} #{price.to_i.to_fs(:delimited)}"
  end

  private

  def clear_pricing_for_information_events
    return unless information?

    self.price = nil
    self.currency = nil
  end

  def blank_camp_detail?(attributes)
      attributes["id"].blank? &&
      attributes["flyer"].blank? &&
      attributes["area_id"].blank? &&
      attributes["notes"].blank? &&
      attributes["registration_link"].blank?
  end
end
