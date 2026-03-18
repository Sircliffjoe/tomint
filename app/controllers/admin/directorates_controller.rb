module Admin
  class DirectoratesController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_admin!
    before_action :set_directorate, only: %i[ edit update destroy ]

    def index
      @directorates = Directorate.all.order(:name)
    end

    def new
      @directorate = Directorate.new
    end

    def edit
    end

    def create
      @directorate = Directorate.new(directorate_params)

      if @directorate.save
        redirect_to admin_directorates_path, notice: "Directorate was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @directorate.update(directorate_params)
        redirect_to admin_directorates_path, notice: "Directorate was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @directorate.destroy
      redirect_to admin_directorates_path, notice: "Directorate was successfully destroyed."
    end

    private

    def set_directorate
      @directorate = Directorate.find(params[:id])
    end

    def directorate_params
      params.require(:directorate).permit(:name, :description)
    end

    def authorize_admin!
      redirect_to root_path, alert: "Not authorized." unless current_user.super_admin?
    end
  end
end
