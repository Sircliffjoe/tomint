module Admin
  class AnnouncementsController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_admin!
    before_action :set_announcement, only: %i[ show edit update destroy ]

    def index
      @announcements = policy_scope(Announcement).order(created_at: :desc)
    end

    def show
      authorize @announcement
    end

    def new
      @announcement = Announcement.new
      authorize @announcement
    end

    def edit
      authorize @announcement
    end

    def create
      @announcement = Announcement.new(announcement_params)
      authorize @announcement

      if @announcement.save
        redirect_to admin_announcements_path, notice: "Announcement was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      authorize @announcement
      if @announcement.update(announcement_params)
        redirect_to admin_announcements_path, notice: "Announcement was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @announcement
      @announcement.destroy
      redirect_to admin_announcements_path, notice: "Announcement was successfully destroyed."
    end

    private

    def set_announcement
      @announcement = Announcement.find(params[:id])
    end

    def announcement_params
      params.require(:announcement).permit(:title, :description, :priority, :image)
    end

    def authorize_admin!
      redirect_to root_path, alert: "Not authorized." unless current_user.super_admin? || current_user.state_admin? || current_user.state_secretary?
    end
  end
end
