# frozen_string_literal: true

class AskInternalNote < ApplicationRecord
  belongs_to :ask_question
  belongs_to :user

  validates :body, presence: true

  scope :non_safeguarding, -> { where(safeguarding_only: false) }
  scope :safeguarding_restricted, -> { where(safeguarding_only: true) }
  scope :recent, -> { order(created_at: :asc) }
end
