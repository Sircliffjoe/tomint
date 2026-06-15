class BlogPost < ApplicationRecord
  belongs_to :author, class_name: "User"
  has_rich_text :body
  has_one_attached :main_image
  has_many_attached :gallery_images

  validates :title, presence: true
  validates :body, presence: true
  validate :gallery_images_limit

  scope :published, -> { where("published_at <= ?", Time.current) }

  private

  def gallery_images_limit
    return unless gallery_images.attachments.size > 3

    errors.add(:gallery_images, "cannot be more than 3 images")
  end
end
