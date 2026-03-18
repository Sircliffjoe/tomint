class RegistrationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event

  def create
    @registration = @event.registrations.find_or_initialize_by(user: current_user)

    if @registration.persisted?
      redirect_to event_registration_path(@event, @registration), notice: "You are already registered for this event."
      return
    end

    if @event.paid?
      # For paid events, we'll implement Paystack logic here later.
      # For now, we'll mark as pending and redirect to a placeholder payment page or just confirm for testing if no payment gateway is fully configured yet.
      # Ideally: Create registration with status: :pending, then redirect to Paystack.

      # Placeholder logic for MVP
      @registration.status = :confirmed
      @registration.amount_paid = @event.price
      @registration.payment_reference = "PAY-#{SecureRandom.hex(8)}" # Placeholder

      if @registration.save
        redirect_to event_registration_path(@event, @registration), notice: "Registration successful! (Payment simulated)"
      else
        redirect_to event_path(@event), alert: "Unable to register. Please try again."
      end
    else
      # Free event
      @registration.status = :confirmed
      if @registration.save
        redirect_to event_registration_path(@event, @registration), notice: "Successfully registered for #{@event.title}!"
      else
        redirect_to event_path(@event), alert: "Unable to register. Please try again."
      end
    end
  end

  def show
    @registration = @event.registrations.find_by(id: params[:id], user: current_user)

    unless @registration
      redirect_to event_path(@event), alert: "Registration not found."
      return
    end

    qr = RQRCode::QRCode.new(@registration.qr_code_token)
    @svg = qr.as_svg(
      offset: 0,
      color: "000",
      shape_rendering: "crispEdges",
      module_size: 6,
      standalone: true
    )
  end

  def destroy
    @registration = @event.registrations.find_by(id: params[:id], user: current_user)

    if @registration&.destroy
      redirect_to event_path(@event), notice: "Registration cancelled."
    else
      redirect_to event_path(@event), alert: "Could not cancel registration."
    end
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end
end
