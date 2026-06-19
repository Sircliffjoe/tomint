class DonationsController < ApplicationController
  include SpamProtection

  layout "public"
  def new
    @donation = Donation.new
    @donation_form_started_at = form_started_at
  end

  def create
    @donation = Donation.new(donation_params)

    if spam_submission?(:donation)
      redirect_to thank_you_donations_path, notice: "Thank you for your donation."
      return
    end

    @donation.status = :successful # Simulating success for MVP
    @donation.payment_reference = "REF-#{SecureRandom.hex(8)}"

    if @donation.save
      redirect_to thank_you_donations_path(id: @donation.id), notice: "Thank you for your donation!"
    else
      @donation_form_started_at = form_started_at
      render :new, status: :unprocessable_entity
    end
  end

  def thank_you
    @donation = Donation.find_by(id: params[:id])
  end

  private

  def donation_params
    params.require(:donation).permit(:amount, :donor_email, :purpose)
  end
end
