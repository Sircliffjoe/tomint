class Training < ApplicationRecord
  has_many :training_sessions, dependent: :destroy
  belongs_to :state, optional: true
  has_rich_text :description

  validates :title, presence: true
  validates :category, presence: true
end
