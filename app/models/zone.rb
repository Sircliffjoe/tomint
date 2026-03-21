class Zone < ApplicationRecord
  has_many :states, dependent: :nullify

  validates :name, presence: true, uniqueness: true
end
