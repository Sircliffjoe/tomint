class Country < ApplicationRecord
  has_many :states, dependent: :restrict_with_error
  has_many :zones, dependent: :restrict_with_error

  enum :status, { active: 0, inactive: 1 }, default: :active

  before_validation :normalize_code
  before_validation :set_slug

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :code, presence: true, uniqueness: { case_sensitive: false }
  validates :slug, presence: true, uniqueness: { case_sensitive: false }

  scope :ordered, -> { order(:sort_order, :name) }

  def display_contact
    contact_info.presence || [ address, phone, email ].compact_blank.join("\n")
  end

  private

  def normalize_code
    self.code = code.to_s.strip.upcase
  end

  def set_slug
    self.slug = name.to_s.parameterize if slug.blank?
  end
end
