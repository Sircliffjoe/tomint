class Page < ApplicationRecord
  has_rich_text :body

  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true

  before_validation :generate_slug

  def to_param
    slug
  end

  private

  def generate_slug
    self.slug = title.parameterize if slug.blank? && title.present?
  end
end
