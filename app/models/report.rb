class Report < ApplicationRecord
  belongs_to :user
  belongs_to :state
  belongs_to :directorate, optional: true
  belongs_to :report_category

  include ReportTemplateData

  has_rich_text :body
  has_many :comments, as: :commentable

  enum :status, {
    draft: 0,
    submitted: 1,
    reviewed: 2,
    approved: 3
  }, default: :draft

  validates :title, presence: true
  validates :body, presence: true
end
