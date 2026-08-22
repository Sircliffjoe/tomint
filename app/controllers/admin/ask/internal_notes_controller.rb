# frozen_string_literal: true

module Admin
  module Ask
    class InternalNotesController < ApplicationController
      before_action :authenticate_user!
      before_action :set_question

      def create
        @note = @question.ask_internal_notes.build(note_params)
        @note.user = current_user

        if @note.save
          @question.log_action!(current_user, "added_internal_note", "Added internal staff note")
          redirect_to admin_ask_question_path(@question), notice: "Internal note added."
        else
          redirect_to admin_ask_question_path(@question), alert: "Failed to add note: #{@note.errors.full_messages.to_sentence}"
        end
      end

      def destroy
        @note = @question.ask_internal_notes.find(params[:id])
        if current_user.super_admin? || @note.user == current_user
          @note.destroy
          redirect_to admin_ask_question_path(@question), notice: "Note deleted."
        else
          redirect_to admin_ask_question_path(@question), alert: "You are not authorized to delete this note."
        end
      end

      private

      def set_question
        @question = AskQuestion.find_by(public_reference: params[:question_id]) || AskQuestion.find(params[:question_id])
      end

      def note_params
        params.require(:ask_internal_note).permit(:body, :safeguarding_only)
      end
    end
  end
end
