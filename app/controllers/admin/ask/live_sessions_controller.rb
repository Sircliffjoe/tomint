# frozen_string_literal: true

module Admin
  module Ask
    class LiveSessionsController < ApplicationController
      before_action :authenticate_user!
      before_action :ensure_authorized!
      before_action :set_session, only: [
        :show, :edit, :update, :destroy, :start, :pause, :end,
        :moderation, :qr_code, :approve_question, :reject_question,
        :pin_question, :unpin_question, :mark_question_answered
      ]

      def index
        @active_sessions = AskLiveSession.where(status: [ :active, :paused ]).order(created_at: :desc)
        @draft_sessions = AskLiveSession.where(status: :draft).order(created_at: :desc)
        @ended_sessions = AskLiveSession.where(status: [ :ended, :archived ]).order(created_at: :desc).limit(10)
      end

      def new
        @live_session = AskLiveSession.new(
          anonymous_mode: true,
          moderation_required: true,
          voting_enabled: true
        )
        @events = Event.where("start_time >= ? OR start_time IS NULL", 1.month.ago).order(start_time: :desc)
      end

      def create
        @live_session = AskLiveSession.new(session_params)
        @live_session.created_by = current_user

        if @live_session.save
          redirect_to admin_ask_live_session_path(@live_session), notice: "Live Q&A session created successfully!"
        else
          @events = Event.where("start_time >= ? OR start_time IS NULL", 1.month.ago).order(start_time: :desc)
          render :new, status: :unprocessable_entity
        end
      end

      def show
        @pending_questions = @live_session.pending_questions
        @approved_questions = @live_session.approved_questions
        @answered_questions = @live_session.answered_questions
        @public_url = ask_live_session_url(@live_session)
        @display_url = ask_live_display_url(@live_session)
      end

      def edit
        @events = Event.where("start_time >= ? OR start_time IS NULL", 1.month.ago).order(start_time: :desc)
      end

      def update
        if @live_session.update(session_params)
          redirect_to admin_ask_live_session_path(@live_session), notice: "Session settings updated."
        else
          @events = Event.where("start_time >= ? OR start_time IS NULL", 1.month.ago).order(start_time: :desc)
          render :edit, status: :unprocessable_entity
        end
      end

      def start
        @live_session.update!(status: :active, start_at: @live_session.start_at || Time.current)
        redirect_to admin_ask_live_session_path(@live_session), notice: "Session is now LIVE!"
      end

      def pause
        @live_session.update!(status: :paused)
        redirect_to admin_ask_live_session_path(@live_session), notice: "Session paused."
      end

      def end
        @live_session.update!(status: :ended, end_at: Time.current)
        redirect_to admin_ask_live_session_path(@live_session), notice: "Session ended."
      end

      def moderation
        @pending_questions = @live_session.pending_questions
        @approved_questions = @live_session.approved_questions
        @answered_questions = @live_session.answered_questions
        @current_pinned = @live_session.current_question
      end

      def qr_code
        public_url = ask_live_session_url(@live_session)

        respond_to do |format|
          format.html do
            @qr_svg = @live_session.qr_code_svg(public_url)
            @public_url = public_url
          end
          format.svg do
            render inline: @live_session.qr_code_svg(public_url), content_type: "image/svg+xml"
          end
          format.png do
            send_data @live_session.qr_code_png(public_url).to_s, type: "image/png", disposition: "inline"
          end
        end
      end

      def approve_question
        question = @live_session.ask_questions.find(params[:question_id])
        question.update!(
          visibility: :approved_public,
          status: :new_intake,
          reviewed_at: Time.current
        )
        question.log_action!(current_user, "live_approved", "Approved for live stream")

        # Broadcast to participants and display
        Turbo::StreamsChannel.broadcast_prepend_to(
          "live_session_#{@live_session.id}",
          target: "live-questions-list",
          partial: "ask/live/question_card",
          locals: { question: question, live_session: @live_session, voted: false }
        ) rescue nil

        respond_to do |format|
          format.html { redirect_to moderation_admin_ask_live_session_path(@live_session), notice: "Question approved!" }
          format.turbo_stream
        end
      end

      def reject_question
        question = @live_session.ask_questions.find(params[:question_id])
        question.update!(
          visibility: :rejected,
          status: :closed,
          reviewed_at: Time.current,
          closed_at: Time.current
        )
        question.log_action!(current_user, "live_rejected", "Rejected in live session")

        respond_to do |format|
          format.html { redirect_to moderation_admin_ask_live_session_path(@live_session), notice: "Question rejected." }
          format.turbo_stream
        end
      end

      def pin_question
        question = @live_session.ask_questions.find(params[:question_id])
        @live_session.ask_questions.update_all(pinned: false)
        question.update!(pinned: true)
        @live_session.update!(current_question: question)
        question.log_action!(current_user, "live_pinned", "Pinned to live presentation screen")

        # Broadcast to live display screen
        Turbo::StreamsChannel.broadcast_replace_to(
          "live_session_#{@live_session.id}_display",
          target: "display-spotlight-container",
          partial: "ask/live/display_spotlight",
          locals: { question: question, live_session: @live_session }
        ) rescue nil

        respond_to do |format|
          format.html { redirect_to moderation_admin_ask_live_session_path(@live_session), notice: "Question pinned to display screen!" }
          format.turbo_stream
        end
      end

      def unpin_question
        @live_session.ask_questions.update_all(pinned: false)
        @live_session.update!(current_question: nil)

        Turbo::StreamsChannel.broadcast_replace_to(
          "live_session_#{@live_session.id}_display",
          target: "display-spotlight-container",
          partial: "ask/live/display_spotlight",
          locals: { question: nil, live_session: @live_session }
        ) rescue nil

        respond_to do |format|
          format.html { redirect_to moderation_admin_ask_live_session_path(@live_session), notice: "Question unpinned." }
          format.turbo_stream
        end
      end

      def mark_question_answered
        question = @live_session.ask_questions.find(params[:question_id])
        question.update!(status: :answered, answered_at: Time.current, pinned: false)
        @live_session.update!(current_question: nil) if @live_session.current_question == question
        question.log_action!(current_user, "live_answered", "Marked as answered live")

        respond_to do |format|
          format.html { redirect_to moderation_admin_ask_live_session_path(@live_session), notice: "Marked as answered." }
          format.turbo_stream
        end
      end

      def destroy
        @live_session.destroy
        redirect_to admin_ask_live_sessions_path, notice: "Live session deleted."
      end

      private

      def set_session
        @live_session = AskLiveSession.find_by(slug: params[:id]) || AskLiveSession.find(params[:id])
      end

      def ensure_authorized!
        unless current_user.super_admin? || current_user.can_manage_live_sessions? || current_user.can_moderate_ask?
          redirect_to admin_ask_dashboard_path, alert: "You are not authorized to manage live sessions."
        end
      end

      def session_params
        params.require(:ask_live_session).permit(
          :title,
          :description,
          :event_id,
          :status,
          :start_at,
          :end_at,
          :anonymous_mode,
          :moderation_required,
          :voting_enabled,
          :display_mode
        )
      end
    end
  end
end
