module Admin
  class CountriesController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_admin!
    before_action :set_country, only: %i[ show edit update destroy ]

    def index
      @countries = Country.includes(:states, :zones).ordered
    end

    def show
    end

    def new
      @country = Country.new
    end

    def edit
    end

    def create
      @country = Country.new(country_params)

      if @country.save
        redirect_to admin_countries_path, notice: "Country was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      if @country.update(country_params)
        redirect_to admin_countries_path, notice: "Country was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @country.destroy
        redirect_to admin_countries_path, notice: "Country was successfully deleted."
      else
        redirect_to admin_country_path(@country), alert: @country.errors.full_messages.to_sentence
      end
    end

    private

    def set_country
      @country = Country.find(params[:id])
    end

    def country_params
      params.require(:country).permit(:name, :code, :status, :description, :contact_info, :phone, :email, :address, :sort_order)
    end

    def authorize_admin!
      redirect_to root_path, alert: "Not authorized." unless current_user.super_admin?
    end
  end
end
