class State < ApplicationRecord
  has_one_attached :map_image

  belongs_to :country
  belongs_to :zone, optional: true
  has_many :users
  has_many :reports, dependent: :destroy
  has_many :areas, dependent: :destroy

  enum :status, { active: 0, inactive: 1 }, default: :active

  before_validation :assign_default_country, on: :create
  before_validation :normalize_code

  validates :name, presence: true, uniqueness: { scope: :country_id, case_sensitive: false }
  validates :code, presence: true, uniqueness: { scope: :country_id, case_sensitive: false }
  validate :zone_country_matches_state_country

  scope :ordered, -> { order(:name) }

  def country=(value)
    if value.is_a?(Country) || value.nil?
      super
    else
      self[:country] = value
      self.country_id ||= Country.find_by(name: value.to_s)&.id || default_country.id
    end
  end

  def location_label
    "#{name}, #{country.name}"
  end

  private

  def assign_default_country
    self.country ||= Country.find_by(code: country_code_from_legacy) || default_country
  end

  def country_code_from_legacy
    return "NG" if self[:country].blank? || self[:country].casecmp("Nigeria").zero?

    self[:country].to_s.first(2).upcase
  end

  def normalize_code
    self.code = code.to_s.strip.upcase
  end

  def default_country
    Country.find_or_create_by!(code: "NG") do |country|
      country.name = "Nigeria"
      country.status = :active
      country.sort_order = 0
    end
  end

  def zone_country_matches_state_country
    return if zone.blank? || country.blank? || zone.country_id == country_id

    errors.add(:zone, "must belong to the same country")
  end
end
