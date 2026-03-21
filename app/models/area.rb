class Area < ApplicationRecord
  belongs_to :state
  belongs_to :area_leader, class_name: "User", optional: true

  validates :name, presence: true
  validates :name, uniqueness: { scope: :state_id }
end
