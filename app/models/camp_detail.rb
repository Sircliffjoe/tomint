require "uri"
require "erb"

class CampDetail < ApplicationRecord
  attr_accessor :area_row

  belongs_to :event
  belongs_to :state, optional: true
  belongs_to :area, optional: true
  has_one_attached :flyer
  has_rich_text :formatted_notes

  before_validation :sync_state_name

  validates :state_name, presence: true
  validates :area_id, presence: true, if: :area_row?
  validate :area_belongs_to_selected_state
  validate :unique_event_location
  validates :registration_link,
            format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), allow_blank: true }

  scope :ordered, -> { order(:position, :state_name) }

  def self.state_reference_available?
    return true if column_names.include?("state_id")

    reset_column_information
    column_names.include?("state_id")
  end

  def area_label
    area&.name || "Main Camp"
  end

  def state_label
    return state_name unless self.class.state_reference_available?

    state&.name || state_name
  end

  def country_label
    return nil unless self.class.state_reference_available?

    state&.country&.name
  end

  def public_content?
    flyer.attached? || registration_link.present? || area_id.present? || custom_notes?
  end

  def custom_notes?
    formatted_notes_content? || legacy_custom_notes?
  end

  def public_notes_html
    return formatted_notes.to_s if formatted_notes_content?
    return ERB::Util.html_escape(notes).to_s if legacy_custom_notes?

    "Camp details will be updated soon."
  end

  def area_row?
    area_row.to_s == "1"
  end

  def location_key
    [ state_name.to_s.strip.downcase, area_id.presence || "main" ]
  end

  def completeness_score
    [
      flyer.attached?,
      registration_link.present?,
      formatted_notes_content?,
      legacy_custom_notes?,
      area_id.present?
    ].count(true)
  end

  private

  def sync_state_name
    return unless self.class.state_reference_available?

    self.state_name = state.name if state.present?
  end

  def area_belongs_to_selected_state
    return unless self.class.state_reference_available?
    return if area.blank? || state.blank? || area.state_id == state_id

    errors.add(:area, "must belong to the selected state or region")
  end

  def unique_event_location
    return if event.blank?

    duplicate = event.camp_details
      .reject { |detail| detail.equal?(self) || detail.marked_for_destruction? }
      .any? do |detail|
        same_state = detail.state_name.to_s.strip.casecmp?(state_name.to_s.strip)
        same_state && detail.area_id.to_i == area_id.to_i
      end

    errors.add(:base, "already has camp details for this location") if duplicate
  end

  def formatted_notes_content?
    formatted_notes&.body&.to_plain_text.to_s.strip.present?
  end

  def legacy_custom_notes?
    notes.present? && !notes.match?(/\ACamp details will be updated once the (state|FCT) flyer is ready\.\z/)
  end
end
