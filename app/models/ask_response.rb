# frozen_string_literal: true

class AskResponse < ApplicationRecord
  belongs_to :ask_question
  belongs_to :user

  enum :response_type, {
    public_answer: 0,
    private_reply: 1,
    pastoral_note: 2
  }

  enum :visibility, {
    public_visible: 0,
    private_only: 1,
    internal_only: 2
  }

  enum :status, {
    draft: 0,
    under_review: 1,
    approved: 2,
    published: 3,
    sent: 4
  }

  validates :body, presence: true

  scope :published, -> { where(status: :published) }
  scope :recent, -> { order(created_at: :desc) }

  def publish!
    transaction do
      update!(
        status: :published,
        published_at: Time.current,
        visibility: :public_visible
      )
      ask_question.update!(
        status: :answered,
        answered_at: Time.current,
        visibility: :approved_public
      )
      ask_question.log_action!(user, "published_response", "Response #{id} published")
    end
  end

  def send_private!
    transaction do
      update!(
        status: :sent,
        sent_at: Time.current,
        visibility: :private_only
      )
      ask_question.update!(
        status: :answered,
        answered_at: Time.current
      )
      ask_question.log_action!(user, "sent_private_response", "Private response #{id} sent")
    end
  end
end
