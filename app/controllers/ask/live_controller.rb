# frozen_string_literal: true

module Ask
  class LiveController < ApplicationController
    layout "public"
    before_action :set_session, only: [ :show, :display, :create_question, :vote ]

    def index
      if params[:code].present?
        clean_code = params[:code].to_s.strip.upcase
        session_match = AskLiveSession.find_by(access_code: clean_code) || AskLiveSession.find_by(slug: params[:code].to_s.strip)
        if session_match
          redirect_to ask_live_session_path(session_match)
          return
        else
          flash.now[:alert] = "No live session found with code '#{clean_code}'. Please verify the code."
        end
      end

      @active_sessions = AskLiveSession.open_sessions
    end

    def show
      @voter_token = session[:ask_voter_token] ||= SecureRandom.uuid
      @questions = @live_session.approved_questions
      @new_question = AskQuestion.new
      @voted_question_ids = AskVote.where(ask_question_id: @questions.pluck(:id), voter_token: @voter_token).pluck(:ask_question_id).to_set
    end

    def display
      render layout: "public"
    end

    def create_question
      unless @live_session.accepting_questions?
        respond_to do |format|
          format.html { redirect_to ask_live_session_path(@live_session), alert: "This session is not currently accepting questions." }
          format.turbo_stream do
            render turbo_stream: turbo_stream.replace(
              "live-form-feedback",
              partial: "ask/live/feedback",
              locals: { message: "This session is not currently accepting questions.", error: true }
            )
          end
        end
        return
      end

      voter_token = session[:ask_voter_token] ||= SecureRandom.uuid
      rate_check = Ask::RateLimiter.check_submission(request, params, voter_token)

      unless rate_check[:allowed]
        respond_to do |format|
          format.html { redirect_to ask_live_session_path(@live_session), alert: rate_check[:reason] }
          format.turbo_stream do
            render turbo_stream: turbo_stream.replace(
              "live-form-feedback",
              partial: "ask/live/feedback",
              locals: { message: rate_check[:reason], error: true }
            )
          end
        end
        return
      end

      @question = @live_session.ask_questions.build(live_question_params)
      @question.submission_type = :live_question
      @question.response_preference = :public_answer
      @question.anonymous_identifier = voter_token
      @question.ip_hash = rate_check[:ip_hash]

      # Apply safeguarding checks
      Ask::SafeguardingDetector.apply_to_question!(@question)

      if @question.safeguarding_flag?
        @question.visibility = :safeguarding_restricted
        @question.status = :safeguarding_review
      elsif @live_session.moderation_required?
        @question.visibility = :pending_review
        @question.status = :new_intake
      else
        @question.visibility = :approved_public
        @question.status = :new_intake
      end

      if @question.save
        # Broadcast to session moderation queue
        broadcast_to_moderator(@question)

        # If auto-approved, broadcast to participants
        if @question.approved_public?
          broadcast_to_participants(@question)
        end

        respond_to do |format|
          format.html { redirect_to ask_live_session_path(@live_session), notice: "Question submitted!" }
          format.turbo_stream
        end
      else
        respond_to do |format|
          format.html { redirect_to ask_live_session_path(@live_session), alert: @question.errors.full_messages.to_sentence }
          format.turbo_stream do
            render turbo_stream: turbo_stream.replace(
              "live-form-feedback",
              partial: "ask/live/feedback",
              locals: { message: @question.errors.full_messages.to_sentence, error: true }
            )
          end
        end
      end
    end

    def vote
      unless @live_session.can_vote?
        render json: { success: false, error: "Voting is currently paused or disabled." }, status: :unprocessable_entity
        return
      end

      @question = @live_session.ask_questions.find_by(public_reference: params[:id]) ||
                  @live_session.ask_questions.find_by(id: params[:id])

      if @question.nil?
        render json: { success: false, error: "Question not found." }, status: :not_found
        return
      end

      voter_token = session[:ask_voter_token] ||= SecureRandom.uuid

      rate_check = Ask::RateLimiter.check_vote(request, @question.id, voter_token)
      unless rate_check[:allowed]
        respond_to do |format|
          format.html { redirect_to ask_live_session_path(@live_session), alert: rate_check[:reason] }
          format.turbo_stream do
            render turbo_stream: turbo_stream.replace(
              "vote-feedback-#{@question.id}",
              partial: "ask/live/vote_feedback",
              locals: { question: @question, message: rate_check[:reason], error: true }
            )
          end
          format.json { render json: { success: false, error: rate_check[:reason] }, status: :unprocessable_entity }
        end
        return
      end

      if @question.upvote_by!(voter_token, rate_check[:ip_hash])
        broadcast_vote_update(@question)

        respond_to do |format|
          format.html { redirect_to ask_live_session_path(@live_session) }
          format.turbo_stream
          format.json { render json: { success: true, upvotes_count: @question.upvotes_count } }
        end
      else
        respond_to do |format|
          format.html { redirect_to ask_live_session_path(@live_session), alert: "Unable to record vote." }
          format.turbo_stream
          format.json { render json: { success: false, error: "Vote already recorded" }, status: :unprocessable_entity }
        end
      end
    end

    private

    def set_session
      @live_session = AskLiveSession.find_by(slug: params[:slug]) ||
                      AskLiveSession.find_by(access_code: params[:slug].to_s.upcase) ||
                      AskLiveSession.find_by(id: params[:slug])

      if @live_session.nil?
        redirect_to ask_live_index_path, alert: "Live session not found."
      end
    end

    def live_question_params
      params.require(:ask_question).permit(:body)
    end

    def broadcast_to_moderator(question)
      Turbo::StreamsChannel.broadcast_prepend_to(
        "live_session_#{@live_session.id}_moderation",
        target: "pending-questions-list",
        partial: "admin/ask/live_sessions/moderation_question_card",
        locals: { question: question, live_session: @live_session }
      ) rescue nil
    end

    def broadcast_to_participants(question)
      Turbo::StreamsChannel.broadcast_prepend_to(
        "live_session_#{@live_session.id}",
        target: "live-questions-list",
        partial: "ask/live/question_card",
        locals: { question: question, live_session: @live_session, voted: false }
      ) rescue nil
    end

    def broadcast_vote_update(question)
      Turbo::StreamsChannel.broadcast_replace_to(
        "live_session_#{@live_session.id}",
        target: "question-votes-#{question.id}",
        partial: "ask/live/vote_button",
        locals: { question: question, live_session: @live_session, voted: true }
      ) rescue nil

      Turbo::StreamsChannel.broadcast_replace_to(
        "live_session_#{@live_session.id}_display",
        target: "display-votes-#{question.id}",
        partial: "ask/live/display_votes",
        locals: { question: question }
      ) rescue nil
    end
  end
end
