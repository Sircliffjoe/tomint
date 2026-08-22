# frozen_string_literal: true

module Admin
  module Ask
    class AnalyticsController < ApplicationController
      before_action :authenticate_user!
      before_action :ensure_authorized!

      def index
        @total_questions = AskQuestion.count
        @public_answered = AskQuestion.where(visibility: :approved_public, status: :answered).count
        @private_requests = AskQuestion.where(response_preference: :private_response).count
        @help_requests = AskQuestion.where(response_preference: :need_help).count
        @safeguarding_count = AskQuestion.where(safeguarding_flag: true).count
        @urgent_count = AskQuestion.where(urgent_flag: true).count

        # By category
        @category_breakdown = AskCategory.joins(:ask_questions)
                                          .group("ask_categories.name")
                                          .count

        # By response preference
        @preference_breakdown = AskQuestion.group(:response_preference).count.transform_keys(&:humanize)

        # By submission type
        @type_breakdown = AskQuestion.group(:submission_type).count.transform_keys(&:humanize)

        # Live sessions stats
        @total_live_sessions = AskLiveSession.count
        @total_live_questions = AskQuestion.where(submission_type: :live_question).count
        @total_live_votes = AskVote.count

        # Monthly trends (last 6 months)
        @monthly_trends = AskQuestion.where("submitted_at >= ?", 6.months.ago.beginning_of_month)
                                     .group("DATE_TRUNC('month', submitted_at)")
                                     .count
                                     .transform_keys { |k| k.strftime("%b %Y") }

        # Top answered questions by views/votes
        @top_questions = AskQuestion.public_library.popular.limit(5)
      end

      private

      def ensure_authorized!
        unless current_user.super_admin? || current_user.can_moderate_ask?
          redirect_to admin_ask_dashboard_path, alert: "You are not authorized to view analytics."
        end
      end
    end
  end
end
