class Announcement < ApplicationRecord
  has_one_attached :image

  validates :title, presence: true
  validates :description, presence: true
end
