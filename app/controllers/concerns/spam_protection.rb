module SpamProtection
  extend ActiveSupport::Concern

  MINIMUM_FORM_SECONDS = 3
  RATE_LIMIT = 5
  RATE_LIMIT_WINDOW = 10.minutes

  private

  def spam_submission?(scope)
    honeypot_filled?(scope) || submitted_too_quickly?(scope) || rate_limited?(scope)
  end

  def form_started_at
    Time.current.to_i
  end

  def honeypot_filled?(scope)
    params[:website].present? || params.dig(scope, :website).present?
  end

  def submitted_too_quickly?(scope)
    started_at = params[:form_started_at].presence || params.dig(scope, :form_started_at).presence
    return true if started_at.blank?
    return true unless started_at.to_s.match?(/\A\d+\z/)

    Time.current.to_i - started_at.to_i < MINIMUM_FORM_SECONDS
  end

  def rate_limited?(scope)
    key = "public-form:#{scope}:#{request.remote_ip}"
    count = Rails.cache.read(key).to_i
    return true if count >= RATE_LIMIT

    Rails.cache.write(key, count + 1, expires_in: RATE_LIMIT_WINDOW)
    false
  end
end
