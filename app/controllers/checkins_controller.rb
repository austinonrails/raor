class CheckinsController < ApplicationController
  load_and_authorize_resource
  before_filter :authenticate_user!

  def index
    @event = Event.find(params[:event_id])
    @checkins = @event.checkins

    respond_to do |format|
      format.html
      format.json do
        render :json => {:success => true, :checkins => @checkins.as_json(:include => [:user])}
      end
    end
  end

  def show
    @event = Event.find(params[:event_id])
    @checkin = @event.checkins.find_by_id(params[:id]) unless @event.blank?

    respond_to do |format|
      format.html
      format.json do
        render :json => {:success => true, :checkin => @checkin}
      end
    end
  end

  def new
    @event = Event.find(params[:event_id])
    @checkin = Checkin.new
  end

  def create
    event = Event.find(params[:event_id])
    if event && (checkin = event.checkin(current_user))
      flash[:notice] = "Successfully checked in to event #{event.name}"
      redirect_to edit_event_checkin_path(event, checkin)
    else
      flash[:error] = "Failed to check in to event #{event.name}"
      redirect_to new_event_path
    end
  end

  def edit
    @event = Event.find(params[:event_id])
    @checkin = @event.checkins.find_by_id(params[:id]) unless @event.blank?
  end

  def update
    if params[:checkin]
      @checkin = Checkin.find(params[:id])
      if @checkin.update_attributes(params[:checkin])
        flash[:notice] = "Successfully updated checkin status for #{@checkin.event.name}"
        redirect_to event_path(@checkin.event)
      else
        flash[:error] = "Failed to update checkin status"
        redirect_to new_event_path
      end
    else
      @event = Event.find(params[:event_id])
      if @event && @event.checkin(current_user)
        flash[:notice] = "Successfully checked in to event #{@event.name}"
        redirect_to event_path(@event)
      else
        flash[:error] = "Failed to check in to event #{@event.name}"
        redirect_to new_event_path
      end
    end
  end

  def destroy
    @event = Event.find(params[:id])
    @event.checkout(current_user) unless @event.blank?
  end
end
