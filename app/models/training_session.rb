class TrainingSession < ApplicationRecord
  belongs_to :training
  has_many_attached :resources

  validates :title, presence: true
  validates :media_url, presence: true
end
