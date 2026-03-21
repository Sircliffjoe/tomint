class State < ApplicationRecord
  belongs_to :zone, optional: true
  has_many :users
  has_many :reports, dependent: :destroy
  has_many :areas, dependent: :destroy

  enum :status, { active: 0, inactive: 1 }, default: :active

  validates :name, presence: true, uniqueness: true
  validates :code, presence: true, uniqueness: true
end
