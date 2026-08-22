# frozen_string_literal: true

class AskModerationAction < ApplicationRecord
  belongs_to :ask_question
  belongs_to :user

  validates :action, presence: true

  scope :recent, -> { order(created_at: :desc) }
end
