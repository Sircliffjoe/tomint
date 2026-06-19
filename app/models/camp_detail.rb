require "uri"
require "erb"

class CampDetail < ApplicationRecord
  attr_accessor :area_row

  belongs_to :event
  belongs_to :area, optional: true
  has_one_attached :flyer
  has_rich_text :formatted_notes

  validates :state_name, presence: true
  validates :area_id, presence: true, if: :area_row?
  validates :registration_link,
            format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), allow_blank: true }

  scope :ordered, -> { order(:position, :state_name) }

  def area_label
    area&.name || "Main Camp"
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

  private

  def formatted_notes_content?
    formatted_notes&.body&.to_plain_text.to_s.strip.present?
  end

  def legacy_custom_notes?
    notes.present? && !notes.match?(/\ACamp details will be updated once the (state|FCT) flyer is ready\.\z/)
  end
end
