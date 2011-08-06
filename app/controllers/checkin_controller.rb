class CheckinController < ApplicationController
  load_and_authorize_resource
  before_filter :authenticate_user!

  def index
    @event = Event.find(params[:event_id])
    @checkins = @event.checkins
  end

  def show
    @event = Event.find(params[:event_id])
    @checkin = @event.checkins.find_by_id(params[:id]) unless @event.blank?
  end

  def new
    @event = Event.find(params[:event_id])
    @checkin = Checkin.new
  end

  def create
    @event = Event.find(params[:event_id])
    if @event && @event.checkin(current_user)
      flash[:notice] = "Successfully checked in to event #{@event.name}"
      redirect_to event_path(@event)
    else
      flash[:error] = "Failed to check in to event #{@event.name}"
      redirect_to new_event_path
    end
  end

  def edit
    @event = Event.find(params[:event_id])
    @checkin = @event.checkins.find_by_id(params[:id]) unless @event.blank?
  end

  def update
    @event = Event.find(params[:event_id])
    if @event && @event.checkin(current_user)
      flash[:notice] = "Successfully checked in to event #{@event.name}"
      redirect_to event_path(@event)
    else
      flash[:error] = "Failed to check in to event #{@event.name}"
      redirect_to new_event_path
    end
  end

  def destroy
    @event = Event.find(params[:id])
    @event.checkout(current_user) unless @event.blank?
  end
end
