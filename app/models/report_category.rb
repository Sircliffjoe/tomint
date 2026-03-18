class ReportCategory < ApplicationRecord
  belongs_to :directorate, optional: true
  has_many :reports

  validates :name, presence: true, uniqueness: { scope: :directorate_id }
end
