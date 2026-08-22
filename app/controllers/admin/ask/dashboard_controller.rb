# frozen_string_literal: true

module Admin
  module Ask
    class DashboardController < ApplicationController
      before_action :authenticate_user!
      before_action :ensure_authorized!

      def index
        @stats = {
          new_intake: AskQuestion.where(status: :new_intake, safeguarding_flag: false).count,
          under_review: AskQuestion.where(status: :under_review, safeguarding_flag: false).count,
          awaiting_response: AskQuestion.where(status: :awaiting_response, safeguarding_flag: false).count,
          follow_up: AskQuestion.where(status: :follow_up_required, safeguarding_flag: false).count,
          answered: AskQuestion.where(status: :answered, safeguarding_flag: false).count,
          closed: AskQuestion.where(status: :closed, safeguarding_flag: false).count,
          safeguarding: current_user.can_access_safeguarding? ? AskQuestion.where(safeguarding_flag: true).count : nil,
          urgent: current_user.can_access_safeguarding? ? AskQuestion.where(urgent_flag: true).count : nil,
          live_sessions: AskLiveSession.where(status: :active).count
        }

        # Questions awaiting action
        @recent_questions = policy_scope(AskQuestion)
                             .where(safeguarding_flag: false)
                             .where(status: [ :new_intake, :under_review, :awaiting_response ])
                             .order(priority: :desc, submitted_at: :desc)
                             .limit(8)

        # Active live sessions
        @active_sessions = AskLiveSession.open_sessions.limit(4)

        # Recent moderation actions
        @recent_actions = AskModerationAction.includes(:user, :ask_question).recent.limit(10)
      end

      private

      def ensure_authorized!
        unless current_user.super_admin? || current_user.can_moderate_ask? || current_user.can_respond_ask? || current_user.can_manage_live_sessions?
          redirect_to root_path, alert: "You are not authorized to access TOM ASK administration."
        end
      end
    end
  end
end
