module Sluggable
  extend ActiveSupport::Concern

  included do
    before_validation :generate_slug, if: -> { slug.blank? }

    validates :slug, presence: true, uniqueness: true
  end

  class_methods do
    def friendly_find(value)
      find_by!(slug: value)
    rescue ActiveRecord::RecordNotFound
      raise unless value.to_s.match?(/\A\d+\z/)

      find(value)
    end
  end

  def to_param
    slug.presence || id.to_s
  end

  private

  def generate_slug
    return if title.blank?

    base = title.parameterize.presence || self.class.model_name.singular
    candidate = base
    suffix = 2
    slug_scope = self.class.where.not(id: id)

    while slug_scope.exists?(slug: candidate)
      candidate = "#{base}-#{suffix}"
      suffix += 1
    end

    self.slug = candidate
  end
end
