class Directorate < ApplicationRecord
  has_many :users
  belongs_to :director, class_name: "User", foreign_key: "director_user_id", optional: true

  validates :name, presence: true, uniqueness: true
end
