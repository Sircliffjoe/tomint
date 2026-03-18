class DonationsController < ApplicationController
  layout "public"
  def new
    @donation = Donation.new
  end

  def create
    @donation = Donation.new(donation_params)
    @donation.status = :successful # Simulating success for MVP
    @donation.payment_reference = "REF-#{SecureRandom.hex(8)}"

    if @donation.save
      redirect_to thank_you_donations_path(id: @donation.id), notice: "Thank you for your donation!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def thank_you
    @donation = Donation.find(params[:id])
  end

  private

  def donation_params
    params.require(:donation).permit(:amount, :donor_email, :purpose)
  end
end
