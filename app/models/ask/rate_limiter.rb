# frozen_string_literal: true

module Ask
  class RateLimiter
    class << self
      def check_submission(request, params, session_token)
        ip = request.remote_ip
        ip_hash = Digest::SHA256.hexdigest(ip.to_s)[0..15]

        # 1. Honeypot check
        if params[:website_hp].present? || params[:honey_field].present?
          return { allowed: false, reason: "Spam detected." }
        end

        # 2. Check recent submission velocity from this IP/token
        cutoff_short = 5.seconds.ago
        cutoff_long = 1.hour.ago

        recent_fast_count = AskQuestion.where("created_at >= ?", cutoff_short)
                                      .where("ip_hash = ? OR anonymous_identifier = ?", ip_hash, session_token)
                                      .count

        if recent_fast_count >= 2
          return { allowed: false, reason: "Please wait a moment before submitting again." }
        end

        recent_hour_count = AskQuestion.where("created_at >= ?", cutoff_long)
                                       .where("ip_hash = ? OR anonymous_identifier = ?", ip_hash, session_token)
                                       .count

        if recent_hour_count >= 20
          return { allowed: false, reason: "Submission limit reached for this hour. Please try again later." }
        end

        # 3. Duplicate check within 10 minutes
        body = params.dig(:ask_question, :body).to_s.strip
        if body.present?
          duplicate_exists = AskQuestion.where("created_at >= ?", 10.minutes.ago)
                                       .where(body: body)
                                       .where("ip_hash = ? OR anonymous_identifier = ?", ip_hash, session_token)
                                       .exists?
          if duplicate_exists
            return { allowed: false, reason: "This question was already recently submitted." }
          end
        end

        { allowed: true, ip_hash: ip_hash }
      end

      def check_vote(request, question_id, voter_token)
        ip = request.remote_ip
        ip_hash = Digest::SHA256.hexdigest(ip.to_s)[0..15]

        # Check if already voted
        if AskVote.exists?(ask_question_id: question_id, voter_token: voter_token)
          return { allowed: false, reason: "You have already voted for this question." }
        end

        # Check vote velocity from this IP
        recent_votes = AskVote.where("created_at >= ?", 1.minute.ago)
                              .where("ip_hash = ? OR voter_token = ?", ip_hash, voter_token)
                              .count

        if recent_votes >= 30
          return { allowed: false, reason: "Voting too fast. Please slow down." }
        end

        { allowed: true, ip_hash: ip_hash }
      end
    end
  end
end
