# frozen_string_literal: true

module Admin
  module Ask
    class ResponsesController < ApplicationController
      before_action :authenticate_user!
      before_action :set_question, only: [ :create ]
      before_action :set_response, only: [ :update, :publish, :send_private, :destroy ]

      def create
        @response = @question.ask_responses.build(response_params)
        @response.user = current_user
        authorize @response

        if @response.save
          @question.update(status: :response_drafted) if @question.awaiting_response?
          @question.log_action!(current_user, "drafted_response", "Response draft created")

          if params[:commit_action] == "publish"
            authorize @response, :publish?
            @response.publish!
            # If submitter provided email, send notification
            AskMailer.response_published_notification(@question).deliver_later rescue nil
            redirect_to admin_ask_question_path(@question), notice: "Response published and question marked as Answered!"
          else
            redirect_to admin_ask_question_path(@question), notice: "Draft response saved."
          end
        else
          redirect_to admin_ask_question_path(@question), alert: "Failed to save response: #{@response.errors.full_messages.to_sentence}"
        end
      end

      def update
        authorize @response

        if @response.update(response_params)
          @response.ask_question.log_action!(current_user, "updated_response", "Response updated")
          redirect_to admin_ask_question_path(@response.ask_question), notice: "Response updated."
        else
          redirect_to admin_ask_question_path(@response.ask_question), alert: "Failed to update: #{@response.errors.full_messages.to_sentence}"
        end
      end

      def publish
        authorize @response, :publish?
        @response.publish!

        # Notify user if email was provided
        AskMailer.response_published_notification(@response.ask_question).deliver_later rescue nil

        redirect_to admin_ask_question_path(@response.ask_question), notice: "Response published publicly!"
      end

      def send_private
        authorize @response, :update?
        @response.send_private!

        redirect_to admin_ask_question_path(@response.ask_question), notice: "Private response recorded and marked as sent."
      end

      def destroy
        authorize @response
        question = @response.ask_question
        @response.destroy
        redirect_to admin_ask_question_path(question), notice: "Response deleted."
      end

      private

      def set_question
        @question = AskQuestion.find_by(public_reference: params[:question_id]) || AskQuestion.find(params[:question_id])
      end

      def set_response
        @response = AskResponse.find(params[:id])
      end

      def response_params
        params.require(:ask_response).permit(
          :body,
          :response_type,
          :visibility,
          :status
        )
      end
    end
  end
end
