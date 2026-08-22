# frozen_string_literal: true

class AskCategory < ApplicationRecord
  has_many :ask_questions, dependent: :nullify

  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true

  before_validation :generate_slug, on: :create

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(position: :asc, name: :asc) }

  def to_param
    slug
  end

  def color_badge_class
    case color
    when "emerald", "green"
      "bg-emerald-100 text-emerald-800 border-emerald-200"
    when "blue", "sky"
      "bg-sky-100 text-sky-800 border-sky-200"
    when "purple", "indigo"
      "bg-purple-100 text-purple-800 border-purple-200"
    when "amber", "yellow"
      "bg-amber-100 text-amber-800 border-amber-200"
    when "rose", "red"
      "bg-rose-100 text-rose-800 border-rose-200"
    when "orange"
      "bg-orange-100 text-orange-800 border-orange-200"
    else
      "bg-gray-100 text-gray-800 border-gray-200"
    end
  end

  private

  def generate_slug
    self.slug = name.parameterize if slug.blank? && name.present?
  end
end
