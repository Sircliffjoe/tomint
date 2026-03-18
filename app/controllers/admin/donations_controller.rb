module Admin
  class DonationsController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_admin!
    before_action :set_donation, only: %i[ show edit update destroy ]

    def index
      @donations = Donation.all.order(created_at: :desc)
    end

    def show
    end

    def edit
    end

    def update
      if @donation.update(donation_params)
        redirect_to admin_donation_path(@donation), notice: "Donation was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @donation.destroy
      redirect_to admin_donations_path, notice: "Donation was successfully destroyed."
    end

    private

    def set_donation
      @donation = Donation.find(params[:id])
    end

    def donation_params
      params.require(:donation).permit(:amount, :currency, :donor_email, :purpose, :status, :payment_reference)
    end

    def authorize_admin!
      redirect_to root_path, alert: "Not authorized." unless current_user.super_admin?
    end
  end
end
