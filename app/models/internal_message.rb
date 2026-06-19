class InternalMessage < ApplicationRecord
  belongs_to :sender, class_name: "User"
  belongs_to :recipient, class_name: "User"

  validates :subject, :body, presence: true
  validate :sender_and_recipient_are_not_super_admins
  validate :sender_and_recipient_are_different

  scope :recent, -> { order(created_at: :desc) }
  scope :unread, -> { where(read_at: nil) }

  def read?
    read_at.present?
  end

  def mark_read!
    update!(read_at: Time.current) unless read?
  end

  private

  def sender_and_recipient_are_not_super_admins
    errors.add(:sender, "cannot be Super Admin") if sender&.super_admin?
    errors.add(:recipient, "cannot be Super Admin") if recipient&.super_admin?
  end

  def sender_and_recipient_are_different
    errors.add(:recipient, "must be another user") if sender_id.present? && sender_id == recipient_id
  end
end
