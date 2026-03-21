module Admin
  class PagesController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_admin!
    before_action :set_page, only: %i[ edit update destroy ]

    def index
      @pages = Page.all.order(:title)
    end

    def new
      @page = Page.new
    end

    def edit
    end

    def create
      @page = Page.new(page_params)

      if @page.save
        redirect_to admin_pages_path, notice: "Page was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @page.update(page_params)
        redirect_to admin_pages_path, notice: "Page was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @page.destroy
      redirect_to admin_pages_path, notice: "Page was successfully destroyed."
    end

    private

    def set_page
      @page = Page.find_by!(slug: params[:id])
    end

    def page_params
      params.require(:page).permit(:title, :slug, :body, :template)
    end

    def authorize_admin!
      redirect_to root_path, alert: "Not authorized." unless current_user.super_admin?
    end
  end
end
