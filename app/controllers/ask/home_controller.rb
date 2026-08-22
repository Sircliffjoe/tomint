# frozen_string_literal: true

module Ask
  class HomeController < ApplicationController
    layout "public"
    skip_before_action :verify_authenticity_token, only: [ :create ], if: -> { request.format.json? }

    def index
      @categories = AskCategory.active.ordered
      @active_live_sessions = AskLiveSession.open_sessions.limit(3)
      @featured_questions = AskQuestion.public_library.featured.limit(3)
      @recent_answered = AskQuestion.public_library.recent_answered.limit(4)
      @question = AskQuestion.new
    end

    def create
      session_token = session[:ask_anon_token] ||= SecureRandom.uuid
      rate_check = Ask::RateLimiter.check_submission(request, params, session_token)

      unless rate_check[:allowed]
        respond_to do |format|
          format.html do
            redirect_to ask_root_path, alert: rate_check[:reason]
          end
          format.turbo_stream do
            render turbo_stream: [
              turbo_stream.replace(
                "ask-form-container",
                partial: "ask/home/form_error",
                locals: { error: rate_check[:reason] }
              ),
              turbo_stream.replace(
                "floating-ask-widget-body",
                partial: "ask/home/form_error",
                locals: { error: rate_check[:reason] }
              )
            ]
          end
        end
        return
      end

      @question = AskQuestion.new(question_params)
      @question.anonymous_identifier = session_token
      @question.ip_hash = rate_check[:ip_hash]
      @question.user_agent_hash = Digest::SHA256.hexdigest(request.user_agent.to_s)[0..15]
      @question.status = :new_intake
      @question.visibility = :pending_review

      # Apply Safeguarding detection heuristics
      Ask::SafeguardingDetector.apply_to_question!(@question)

      if @question.save
        # If sensitive/safeguarding/urgent, trigger alert to safeguarding leads
        if @question.safeguarding_flag? || @question.urgent_flag?
          notify_safeguarding_team(@question)
        end

        respond_to do |format|
          format.html { redirect_to ask_confirmation_path(reference: @question.public_reference) }
          format.turbo_stream
        end
      else
        @categories = AskCategory.active.ordered
        @active_live_sessions = AskLiveSession.open_sessions.limit(3)
        @featured_questions = AskQuestion.public_library.featured.limit(3)
        @recent_answered = AskQuestion.public_library.recent_answered.limit(4)

        respond_to do |format|
          format.html { render :index, status: :unprocessable_entity }
          format.turbo_stream do
            render turbo_stream: [
              turbo_stream.replace(
                "ask-form-container",
                partial: "ask/home/form",
                locals: { question: @question, categories: @categories }
              ),
              turbo_stream.replace(
                "floating-ask-widget-body",
                partial: "ask/home/floating_form_error",
                locals: { question: @question, categories: @categories }
              )
            ]
          end
        end
      end
    end

    def confirmation
      @reference = params[:reference]
      @question = AskQuestion.find_by(public_reference: @reference)
    end

    def status_check
      @reference = params[:reference].to_s.strip.upcase
      @question = AskQuestion.find_by(public_reference: @reference) if @reference.present?
    end

    private

    def question_params
      params.require(:ask_question).permit(
        :body,
        :ask_category_id,
        :submission_type,
        :response_preference,
        :contact_method,
        :contact_details
      )
    end

    def notify_safeguarding_team(question)
      recipients = User.where(role: [ :super_admin, :responder ]).pluck(:email)
      recipients.each do |email|
        AskMailer.safeguarding_alert(question, email).deliver_later rescue nil
      end
    end
  end
end
