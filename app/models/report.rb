class Report < ApplicationRecord
  belongs_to :user
  belongs_to :state
  belongs_to :directorate
  belongs_to :report_category

  store_accessor :data, :camp_date, :attendees_count, :decisions_count, :location,
                        :year, :total_events, :highlights, :challenges,
                        :quarter, :summary,
                        :training_date, :participants_count, :topic,
                        :total_income, :total_expenses, :currency,
                        :platform, :reach_count, :engagement_count

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
