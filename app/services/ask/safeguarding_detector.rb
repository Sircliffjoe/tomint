# frozen_string_literal: true

module Ask
  class SafeguardingDetector
    # Keyword categories indicative of sensitive / safeguarding / crisis topics
    CRITICAL_KEYWORDS = [
      "kill myself", "suicide", "want to die", "end my life", "cutting myself",
      "self-harm", "self harm", "hanging myself", "overdose", "slit my wrist",
      "rape", "raped", "molest", "molested", "sexual abuse", "touching me",
      "touched me", "unwanted touch", "forced me to", "beat me", "beating me",
      "in danger", "kill me", "threatened to kill", "locked up", "kidnapped",
      "held hostage", "abuse me", "abusing me", "grooming", "forced sex"
    ].freeze

    HIGH_RISK_KEYWORDS = [
      "hurting me", "hurts me", "scared of my", "afraid of my", "touch me inappropriately",
      "secret touches", "drugs", "weapons", "violence", "choking", "blackmail",
      "extortion", "predator", "molestation", "starving me", "run away",
      "running away from home", "don't want to live", "depressed and hopeless",
      "someone is harming", "being abused", "physical abuse", "emotional abuse"
    ].freeze

    class << self
      def analyze(text, submission_type: nil, response_preference: nil)
        return { flagged: false, urgent: false, severity: :low, reasons: [] } if text.blank?

        lower_text = text.downcase
        reasons = []
        is_critical = false
        is_high = false

        # Check critical keywords
        CRITICAL_KEYWORDS.each do |kw|
          if lower_text.include?(kw)
            reasons << "Detected critical term: '#{kw}'"
            is_critical = true
          end
        end

        # Check high-risk keywords
        HIGH_RISK_KEYWORDS.each do |kw|
          if lower_text.include?(kw)
            reasons << "Detected sensitive term: '#{kw}'"
            is_high = true
          end
        end

        # Check explicit user submission choice
        if submission_type.to_s.in?(%w[safeguarding_disclosure urgent_concern])
          reasons << "User selected sensitive submission type (#{submission_type})"
          is_high = true
        end

        if response_preference.to_s == "need_help"
          reasons << "User explicitly requested urgent help"
          is_high = true
        end

        flagged = is_critical || is_high
        urgent = is_critical

        {
          flagged: flagged,
          urgent: urgent,
          severity: is_critical ? :critical : (is_high ? :high : :low),
          reasons: reasons
        }
      end

      def apply_to_question!(question)
        analysis = analyze(
          question.body,
          submission_type: question.submission_type,
          response_preference: question.response_preference
        )

        if analysis[:flagged]
          question.safeguarding_flag = true
          question.urgent_flag = analysis[:urgent]
          question.visibility = :safeguarding_restricted
          question.priority = analysis[:urgent] ? :urgent : :high
          question.status = analysis[:urgent] ? :urgent : :safeguarding_review
          question.moderation_reason = analysis[:reasons].join("; ")
        end

        analysis
      end
    end
  end
end
