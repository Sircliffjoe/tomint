# frozen_string_literal: true

class AskQuestion < ApplicationRecord
  belongs_to :ask_category, counter_cache: :questions_count, optional: true
  belongs_to :ask_live_session, counter_cache: :questions_count, optional: true

  has_many :ask_responses, dependent: :destroy
  has_one :published_response, -> { where(status: :published) }, class_name: "AskResponse"
  has_many :ask_assignments, dependent: :destroy
  has_one :active_assignment, -> { where(active: true) }, class_name: "AskAssignment"
  has_one :current_assignee, through: :active_assignment, source: :assignee
  has_many :ask_internal_notes, dependent: :destroy
  has_many :ask_moderation_actions, dependent: :destroy
  has_many :ask_escalations, dependent: :destroy
  has_many :ask_votes, dependent: :destroy

  enum :submission_type, {
    general_question: 0,
    personal_concern: 1,
    safeguarding_disclosure: 2,
    urgent_concern: 3,
    live_question: 4
  }

  enum :response_preference, {
    public_answer: 0,
    private_response: 1,
    just_listen: 2,
    need_help: 3
  }

  enum :contact_method, {
    none_provided: 0,
    whatsapp: 1,
    email: 2,
    phone: 3,
    other: 4
  }

  enum :visibility, {
    pending_review: 0,
    approved_public: 1,
    private_only: 2,
    internal_only: 3,
    safeguarding_restricted: 4,
    rejected: 5
  }

  enum :status, {
    new_intake: 0,
    under_review: 1,
    awaiting_response: 2,
    response_drafted: 3,
    answered: 4,
    follow_up_required: 5,
    private_conversation: 6,
    safeguarding_review: 7,
    safeguarding_escalated: 8,
    urgent: 9,
    resolved: 10,
    closed: 11
  }

  enum :priority, {
    low: 0,
    normal: 1,
    high: 2,
    urgent: 3
  }, prefix: :priority

  validates :body, presence: true, length: { minimum: 3, maximum: 5000 }
  validates :public_reference, presence: true, uniqueness: true

  before_validation :generate_public_reference, on: :create
  before_create :set_default_timestamps

  scope :public_library, -> { where(visibility: :approved_public, status: :answered, safeguarding_flag: false) }
  scope :featured, -> { where(featured: true) }
  scope :recent_answered, -> { order(answered_at: :desc, updated_at: :desc) }
  scope :popular, -> { order(upvotes_count: :desc, views_count: :desc) }
  scope :safeguarding_queue, -> { where(safeguarding_flag: true).or(where(status: [ :safeguarding_review, :safeguarding_escalated, :urgent ])) }
  scope :moderation_queue, -> { where(safeguarding_flag: false).where(status: [ :new_intake, :under_review, :awaiting_response, :response_drafted, :follow_up_required ]) }
  scope :for_live_session, ->(session_id) { where(ask_live_session_id: session_id) }
  scope :approved_for_live, ->(session_id) { where(ask_live_session_id: session_id, visibility: :approved_public).where.not(status: [ :rejected, :closed ]).order(pinned: :desc, upvotes_count: :desc, created_at: :asc) }

  def to_param
    public_reference
  end

  def display_body
    anonymized_body.presence || body
  end

  def can_publish_publicly?
    !safeguarding_flag? && !urgent_flag? && (public_answer? || live_question?)
  end

  def has_contact_info?
    contact_details.present? && !none_provided?
  end

  def assign_to!(assignee, assigned_by, notes = nil)
    assignment = nil
    transaction do
      ask_assignments.where(active: true).update_all(active: false, completed_at: Time.current)
      assignment = ask_assignments.create!(
        assignee: assignee,
        assigned_by: assigned_by,
        assigned_at: Time.current,
        notes: notes,
        active: true
      )
      self.status = :awaiting_response unless safeguarding_flag?
      save!
      log_action!(assigned_by, "assigned", "Assigned to #{assignee.full_name}#{": #{notes}" if notes.present?}")
    end
    AskMailer.question_assigned(assignment).deliver_later rescue nil
    assignment
  end

  def log_action!(user, action_name, details = nil)
    ask_moderation_actions.create!(
      user: user,
      action: action_name,
      details: details
    )
  end

  def upvote_by!(voter_token, ip_hash = nil)
    return false if voter_token.blank?

    transaction do
      vote = ask_votes.find_or_initialize_by(voter_token: voter_token)
      if vote.new_record?
        vote.ip_hash = ip_hash
        vote.save!
        increment!(:upvotes_count)
        true
      else
        false
      end
    end
  rescue ActiveRecord::RecordNotUnique
    false
  end

  def increment_views!
    increment!(:views_count)
  end

  def status_badge_class
    case status
    when "new_intake"
      "bg-blue-100 text-blue-800 border-blue-200"
    when "under_review"
      "bg-amber-100 text-amber-800 border-amber-200"
    when "awaiting_response", "response_drafted"
      "bg-indigo-100 text-indigo-800 border-indigo-200"
    when "answered", "resolved"
      "bg-emerald-100 text-emerald-800 border-emerald-200"
    when "safeguarding_review", "safeguarding_escalated", "urgent"
      "bg-rose-100 text-rose-800 border-rose-200 font-bold"
    when "closed"
      "bg-gray-100 text-gray-800 border-gray-200"
    else
      "bg-stone-100 text-stone-800 border-stone-200"
    end
  end

  def priority_badge_class
    case priority
    when "urgent"
      "bg-rose-600 text-white font-bold animate-pulse"
    when "high"
      "bg-amber-500 text-white"
    when "normal"
      "bg-stone-100 text-stone-700"
    when "low"
      "bg-gray-100 text-gray-500"
    end
  end

  private

  def generate_public_reference
    return if public_reference.present?

    loop do
      ref = "ASK-#{SecureRandom.alphanumeric(6).upcase}"
      unless AskQuestion.exists?(public_reference: ref)
        self.public_reference = ref
        break
      end
    end
  end

  def set_default_timestamps
    self.submitted_at ||= Time.current
  end
end
