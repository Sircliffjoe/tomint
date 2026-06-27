class Zone < ApplicationRecord
  belongs_to :country
  has_many :states, dependent: :nullify

  before_validation :assign_default_country, on: :create

  validates :name, presence: true, uniqueness: { scope: :country_id, case_sensitive: false }

  scope :ordered, -> { order(:name) }

  private

  def assign_default_country
    self.country ||= Country.find_or_create_by!(code: "NG") do |country|
      country.name = "Nigeria"
      country.status = :active
      country.sort_order = 0
    end
  end
end
