# frozen_string_literal: true

class AskAssignment < ApplicationRecord
  belongs_to :ask_question
  belongs_to :assignee, class_name: "User"
  belongs_to :assigned_by, class_name: "User"

  validates :assigned_at, presence: true

  scope :active, -> { where(active: true) }
  scope :recent, -> { order(assigned_at: :desc) }
end
