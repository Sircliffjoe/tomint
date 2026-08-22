# frozen_string_literal: true

class AskLiveSession < ApplicationRecord
  belongs_to :created_by, class_name: "User"
  belongs_to :event, optional: true
  belongs_to :current_question, class_name: "AskQuestion", optional: true

  has_many :ask_questions, dependent: :nullify
  has_many :approved_questions, -> { where(visibility: :approved_public).where.not(status: [ :rejected, :closed ]).order(pinned: :desc, upvotes_count: :desc, created_at: :asc) }, class_name: "AskQuestion"
  has_many :pending_questions, -> { where(visibility: :pending_review, status: :new_intake).order(created_at: :desc) }, class_name: "AskQuestion"
  has_many :answered_questions, -> { where(status: :answered).order(answered_at: :desc) }, class_name: "AskQuestion"

  enum :status, {
    draft: 0,
    active: 1,
    paused: 2,
    ended: 3,
    archived: 4
  }

  enum :display_mode, {
    standard: 0,
    projector: 1,
    split_screen: 2
  }, prefix: :display

  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :access_code, presence: true, uniqueness: true

  before_validation :generate_slug_and_code, on: :create

  scope :open_sessions, -> { where(status: [ :active, :paused ]).order(start_at: :desc, created_at: :desc) }
  scope :recent, -> { order(created_at: :desc) }

  def to_param
    slug
  end

  def accepting_questions?
    active?
  end

  def can_vote?
    active? && voting_enabled?
  end

  def status_badge_class
    case status
    when "active"
      "bg-green-100 text-green-800 border-green-200"
    when "paused"
      "bg-amber-100 text-amber-800 border-amber-200"
    when "ended"
      "bg-gray-100 text-gray-800 border-gray-200"
    when "draft"
      "bg-blue-100 text-blue-800 border-blue-200"
    else
      "bg-stone-100 text-stone-800 border-stone-200"
    end
  end

  def qr_code_svg(url)
    qrcode = RQRCode::QRCode.new(url)
    qrcode.as_svg(
      color: "000",
      shape_rendering: "crispEdges",
      module_size: 6,
      standalone: true,
      use_path: true
    )
  end

  def qr_code_png(url, size: 300)
    qrcode = RQRCode::QRCode.new(url)
    qrcode.as_png(
      size: size,
      border_modules: 2,
      module_px_size: 6
    )
  end

  private

  def generate_slug_and_code
    if slug.blank? && title.present?
      base_slug = title.parameterize
      candidate = base_slug
      counter = 1
      while AskLiveSession.exists?(slug: candidate)
        candidate = "#{base_slug}-#{counter}"
        counter += 1
      end
      self.slug = candidate
    end

    if access_code.blank?
      loop do
        code = SecureRandom.alphanumeric(6).upcase
        unless AskLiveSession.exists?(access_code: code)
          self.access_code = code
          break
        end
      end
    end
  end
end
