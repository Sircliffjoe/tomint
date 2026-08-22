# frozen_string_literal: true

module Admin
  module Ask
    class SettingsController < ApplicationController
      before_action :authenticate_user!
      before_action :ensure_super_admin!

      def show
        @headline = SystemSetting.ask_headline
        @intro_text = SystemSetting.ask_intro_text
        @privacy_notice = SystemSetting.ask_privacy_notice
        @urgent_help_text = SystemSetting.ask_urgent_help_text
      end

      def update
        SystemSetting.set("ask_headline", params[:ask_headline], description: "TOM ASK landing headline") if params[:ask_headline].present?
        SystemSetting.set("ask_intro_text", params[:ask_intro_text], description: "TOM ASK intro copy") if params[:ask_intro_text].present?
        SystemSetting.set("ask_privacy_notice", params[:ask_privacy_notice], description: "TOM ASK privacy notice") if params[:ask_privacy_notice].present?
        SystemSetting.set("ask_urgent_help_text", params[:ask_urgent_help_text], description: "TOM ASK urgent help message") if params[:ask_urgent_help_text].present?

        redirect_to admin_ask_settings_path, notice: "TOM ASK settings saved successfully."
      end

      private

      def ensure_super_admin!
        unless current_user.super_admin?
          redirect_to admin_ask_dashboard_path, alert: "Only Super Admins can modify global settings."
        end
      end
    end
  end
end
