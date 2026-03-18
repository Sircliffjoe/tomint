class BlogPost < ApplicationRecord
  belongs_to :author, class_name: "User"
  has_rich_text :body

  validates :title, presence: true
  validates :body, presence: true

  scope :published, -> { where("published_at <= ?", Time.current) }
end
