# frozen_string_literal: true

module Admin
  module Ask
    class CategoriesController < ApplicationController
      before_action :authenticate_user!
      before_action :ensure_authorized!
      before_action :set_category, only: [ :edit, :update, :destroy ]

      def index
        @categories = AskCategory.order(position: :asc, name: :asc)
      end

      def new
        @category = AskCategory.new(color: "emerald", position: AskCategory.count + 1)
      end

      def create
        @category = AskCategory.new(category_params)

        if @category.save
          redirect_to admin_ask_categories_path, notice: "Category created successfully."
        else
          render :new, status: :unprocessable_entity
        end
      end

      def edit
      end

      def update
        if @category.update(category_params)
          redirect_to admin_ask_categories_path, notice: "Category updated successfully."
        else
          render :edit, status: :unprocessable_entity
        end
      end

      def destroy
        if @category.ask_questions.exists?
          redirect_to admin_ask_categories_path, alert: "Cannot delete category with associated questions. Deactivate it instead."
        else
          @category.destroy
          redirect_to admin_ask_categories_path, notice: "Category deleted."
        end
      end

      private

      def set_category
        @category = AskCategory.find_by(slug: params[:id]) || AskCategory.find(params[:id])
      end

      def ensure_authorized!
        unless current_user.super_admin? || current_user.can_moderate_ask?
          redirect_to admin_ask_dashboard_path, alert: "You are not authorized to manage categories."
        end
      end

      def category_params
        params.require(:ask_category).permit(
          :name,
          :slug,
          :description,
          :icon,
          :color,
          :position,
          :active
        )
      end
    end
  end
end
