# frozen_string_literal: true

module Admin
  module Ask
    class SafeguardingController < ApplicationController
      before_action :authenticate_user!
      before_action :ensure_safeguarding_access!
      before_action :set_question, only: [ :show, :escalate, :update_status ]

      def index
        @stats = {
          total_flagged: AskQuestion.where(safeguarding_flag: true).count,
          urgent: AskQuestion.where(urgent_flag: true).count,
          under_review: AskQuestion.where(status: :safeguarding_review).count,
          escalated: AskQuestion.where(status: :safeguarding_escalated).count,
          resolved: AskQuestion.where(status: [ :resolved, :closed ]).where(safeguarding_flag: true).count
        }

        scope = AskQuestion.where(safeguarding_flag: true).includes(:ask_category, :ask_escalations)

        if params[:status].present? && params[:status] != "all"
          scope = scope.where(status: params[:status])
        end

        if params[:priority].present?
          scope = scope.where(priority: params[:priority])
        end

        @pagy, @questions = pagy(:offset, scope.order(urgent_flag: :desc, priority: :desc, submitted_at: :desc), limit: 15)
        @active_escalations = AskEscalation.includes(:ask_question, :assigned_safeguarding_lead).active.urgent_first.limit(10)
      end

      def show
        @escalation = @question.ask_escalations.build
        @active_escalation = @question.ask_escalations.active.first
        @safeguarding_leads = User.where(role: [ :super_admin, :safeguarding_lead ])
        @internal_notes = @question.ask_internal_notes.includes(:user).recent
        @moderation_actions = @question.ask_moderation_actions.includes(:user).recent
      end

      def escalate
        @escalation = @question.ask_escalations.build(escalation_params)
        @escalation.created_by = current_user

        if @escalation.save
          @question.update!(
            status: :safeguarding_escalated,
            priority: @escalation.critical? || @escalation.high? ? :urgent : :high
          )
          @question.log_action!(current_user, "escalated", "Safeguarding case escalated: #{@escalation.escalation_type} (#{@escalation.severity})")
          redirect_to admin_ask_safeguarding_path(@question), notice: "Case escalated successfully."
        else
          redirect_to admin_ask_safeguarding_path(@question), alert: "Failed to escalate case: #{@escalation.errors.full_messages.to_sentence}"
        end
      end

      def update_status
        new_status = params[:status]
        if AskQuestion.statuses.key?(new_status)
          @question.update!(
            status: new_status,
            closed_at: new_status.in?(%w[resolved closed]) ? Time.current : nil
          )
          @question.log_action!(current_user, "safeguarding_status_changed", "Status changed to #{new_status.humanize}")
          redirect_to admin_ask_safeguarding_path(@question), notice: "Case status updated to #{new_status.humanize}."
        else
          redirect_to admin_ask_safeguarding_path(@question), alert: "Invalid status."
        end
      end

      private

      def set_question
        @question = AskQuestion.find_by(public_reference: params[:id]) || AskQuestion.find(params[:id])
      end

      def ensure_safeguarding_access!
        unless current_user.can_access_safeguarding?
          redirect_to admin_ask_dashboard_path, alert: "Access restricted: Safeguarding credentials required."
        end
      end

      def escalation_params
        params.require(:ask_escalation).permit(
          :escalation_type,
          :severity,
          :reason,
          :assigned_safeguarding_lead_id,
          :action_taken_notes
        )
      end
    end
  end
end
