class State < ApplicationRecord
  has_many :users
  has_many :reports, dependent: :destroy

  enum :status, { active: 0, inactive: 1 }, default: :active

  validates :name, presence: true, uniqueness: true
  validates :code, presence: true, uniqueness: true, length: { is: 3 } # e.g., 'LAG' for Lagos
end
