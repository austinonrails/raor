class EventsController < ApplicationController
  load_and_authorize_resource  
  before_filter :authenticate_user!

  def index
    @events = Event.current
  end

  def show
    @event = Event.find(params[:id])
  end

  def new
    @event = Event.new
  end

  def create
    @event = Event.create(params[:event])
    if @event
      flash[:notice] = "Successfully created event #{@event.name}"
      redirect_to event_path(@event)
    else
      flash[:error] = "Failed to create event #{@event.name}"
      redirect_to new_event_path
    end
  end

  def edit
    @event = Event.find(params[:id])
  end

  def update
    @event = Event.find(params[:id])
    if params[:event].blank?
      flash[:error] = "Error while trying to update event"
      redirect_to events_path
    elsif @event.update_attributes(params[:event])
      flash[:notice] = "Successfully updated event #{@event.name}"
      redirect_to event_path(@event)
    else
      flash[:error] = "Failed to update event #{@event.name}"
      redirect_to edit_event_path(@event)
    end
  end

  def destroy
    @event = Event.find(params[:id])
    @event.destroy unless @event.blank?
  end
end
