# frozen_string_literal: true

class AskVote < ApplicationRecord
  belongs_to :ask_question

  validates :voter_token, presence: true, uniqueness: { scope: :ask_question_id }
end
