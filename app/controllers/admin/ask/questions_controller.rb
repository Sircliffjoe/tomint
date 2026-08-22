# frozen_string_literal: true

module Admin
  module Ask
    class QuestionsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_question, only: [
        :show, :update, :moderate, :approve_public,
        :reject, :flag_safeguarding, :assign, :close, :reopen, :destroy
      ]
      before_action :authorize_question!, only: [ :show, :update, :destroy ]

      def index
        @categories = AskCategory.ordered
        @responders = User.where(role: [ :super_admin, :ask_moderator, :ask_responder ])

        scope = policy_scope(AskQuestion).includes(:ask_category, :current_assignee, :published_response)

        # Do not include safeguarding questions in standard queue unless specifically filtered by authorized user
        unless params[:safeguarding] == "true" && current_user.can_access_safeguarding?
          scope = scope.where(safeguarding_flag: false)
        end

        if params[:status].present? && params[:status] != "all"
          scope = scope.where(status: params[:status])
        end

        if params[:category_id].present?
          scope = scope.where(ask_category_id: params[:category_id])
        end

        if params[:priority].present?
          scope = scope.where(priority: params[:priority])
        end

        if params[:submission_type].present?
          scope = scope.where(submission_type: params[:submission_type])
        end

        if params[:assignee_id].present?
          scope = scope.joins(:ask_assignments).where(ask_assignments: { assignee_id: params[:assignee_id], active: true })
        end

        if params[:q].present?
          query = "%#{params[:q].to_s.strip}%"
          scope = scope.where("ask_questions.body ILIKE :q OR ask_questions.anonymized_body ILIKE :q OR ask_questions.public_reference ILIKE :q", q: query)
        end

        scope = scope.order(priority: :desc, submitted_at: :desc)
        @pagy, @questions = pagy(:offset, scope, limit: 15)
      end

      def show
        @new_response = @question.ask_responses.build
        @new_internal_note = @question.ask_internal_notes.build
        @responders = User.where(role: [ :super_admin, :ask_moderator, :ask_responder, :safeguarding_lead ])
        @categories = AskCategory.active.ordered
        @internal_notes = @question.ask_internal_notes.includes(:user).recent
        @moderation_actions = @question.ask_moderation_actions.includes(:user).recent
        @responses = @question.ask_responses.includes(:user).recent
      end

      def update
        if @question.update(question_params)
          @question.log_action!(current_user, "updated_details", "Updated question details and classification")
          redirect_to admin_ask_question_path(@question), notice: "Question updated successfully."
        else
          render :show, status: :unprocessable_entity
        end
      end

      def moderate
        authorize @question, :moderate?

        if @question.update(moderation_params)
          @question.log_action!(current_user, "moderated", "Updated moderation settings: status=#{@question.status}, visibility=#{@question.visibility}")
          redirect_to admin_ask_question_path(@question), notice: "Question moderation saved."
        else
          redirect_to admin_ask_question_path(@question), alert: "Failed to update moderation settings: #{@question.errors.full_messages.to_sentence}"
        end
      end

      def approve_public
        authorize @question, :moderate?

        if @question.safeguarding_flag?
          redirect_to admin_ask_question_path(@question), alert: "Safeguarding questions cannot be approved for public view."
          return
        end

        @question.update!(
          visibility: :approved_public,
          status: @question.answered? ? :answered : :awaiting_response,
          reviewed_at: Time.current
        )
        @question.log_action!(current_user, "approved_for_public", "Approved question for public visibility")

        redirect_to admin_ask_question_path(@question), notice: "Question approved for public view."
      end

      def reject
        authorize @question, :moderate?

        reason = params[:moderation_reason].presence || "Does not meet community guidelines"
        @question.update!(
          visibility: :rejected,
          status: :closed,
          moderation_reason: reason,
          reviewed_at: Time.current,
          closed_at: Time.current
        )
        @question.log_action!(current_user, "rejected", "Rejected: #{reason}")

        redirect_to admin_ask_questions_path, notice: "Question was rejected and closed."
      end

      def flag_safeguarding
        authorize @question, :moderate?

        reason = params[:reason].presence || "Flagged by moderator for safeguarding review"
        @question.update!(
          safeguarding_flag: true,
          visibility: :safeguarding_restricted,
          status: :safeguarding_review,
          priority: :high,
          moderation_reason: reason
        )
        @question.log_action!(current_user, "flagged_safeguarding", reason)

        # Notify safeguarding team
        User.where(role: [ :super_admin, :safeguarding_lead ]).find_each do |user|
          AskMailer.safeguarding_alert(@question, user.email).deliver_later rescue nil
        end

        redirect_to admin_ask_questions_path, alert: "Question flagged and moved to Safeguarding Hub."
      end

      def assign
        authorize @question, :assign?

        assignee = User.find(params[:assignee_id])
        notes = params[:notes].to_s.strip

        @question.assign_to!(assignee, current_user, notes)

        # Send notification
        assignment = @question.active_assignment
        AskMailer.question_assigned(assignment).deliver_later rescue nil

        redirect_to admin_ask_question_path(@question), notice: "Assigned to #{assignee.full_name}."
      end

      def close
        authorize @question, :moderate?

        @question.update!(status: :closed, closed_at: Time.current)
        @question.log_action!(current_user, "closed", params[:notes])

        redirect_to admin_ask_question_path(@question), notice: "Question closed."
      end

      def reopen
        authorize @question, :moderate?

        @question.update!(status: :under_review, closed_at: nil)
        @question.log_action!(current_user, "reopened", "Question reopened for review")

        redirect_to admin_ask_question_path(@question), notice: "Question reopened."
      end

      def destroy
        authorize @question, :destroy?
        @question.destroy
        redirect_to admin_ask_questions_path, notice: "Question deleted."
      end

      private

      def set_question
        @question = AskQuestion.find_by(public_reference: params[:id]) || AskQuestion.find(params[:id])
      end

      def authorize_question!
        authorize @question
      end

      def question_params
        params.require(:ask_question).permit(
          :anonymized_body,
          :ask_category_id,
          :priority,
          :status,
          :featured,
          :moderation_reason
        )
      end

      def moderation_params
        params.require(:ask_question).permit(
          :anonymized_body,
          :ask_category_id,
          :priority,
          :status,
          :visibility,
          :featured,
          :moderation_reason
        )
      end
    end
  end
end
