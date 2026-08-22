# frozen_string_literal: true

module Ask
  class QuestionsController < ApplicationController
    layout "public"

    def index
      @categories = AskCategory.active.ordered
      @selected_category = AskCategory.find_by(slug: params[:category]) if params[:category].present?

      scope = AskQuestion.public_library.includes(:ask_category, :published_response)

      if @selected_category
        scope = scope.where(ask_category_id: @selected_category.id)
      end

      if params[:q].present?
        query = "%#{params[:q].to_s.strip}%"
        scope = scope.where("ask_questions.body ILIKE :q OR ask_questions.anonymized_body ILIKE :q", q: query)
      end

      scope = if params[:sort] == "popular"
                scope.order(upvotes_count: :desc, views_count: :desc, answered_at: :desc)
              else
                scope.order(answered_at: :desc, created_at: :desc)
              end

      @pagy, @questions = pagy(:offset, scope, limit: 12)
    end

    def show
      @question = AskQuestion.public_library
                             .includes(:ask_category, published_response: :user)
                             .find_by(public_reference: params[:id]) ||
                  AskQuestion.public_library
                             .includes(:ask_category, published_response: :user)
                             .find_by(id: params[:id])

      if @question.nil?
        redirect_to ask_questions_path, alert: "Question not found or is currently private."
        return
      end

      @question.increment_views!
      @published_response = @question.published_response
      @related_questions = AskQuestion.public_library
                                      .where(ask_category_id: @question.ask_category_id)
                                      .where.not(id: @question.id)
                                      .limit(4)
    end
  end
end
