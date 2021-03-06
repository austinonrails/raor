require 'active_support/inflector'

class EventsController < ApplicationController
  include ActiveSupport::Inflector
  load_resource :event
  authorize_resource :event, :except => :index

  respond_to :html, :json

  def index
    # Must manually authorize due to setting current_user on events
    if can?(:read, Event) && can?(:read, User)
      @events = @events.page(params[:page])
      @events.each{|event| event.current_user = current_user}

      respond_with(@events) do |format|
        format.html do
          render
        end
      end
    end
  end

  def show
    @event.current_user = current_user
    @checkins = if params[:work]
      @event.checkins.employment
    elsif params[:hire]
      @event.checkins.employ
    else
      @event.checkins
    end

    respond_with(@event)
  end

  def new
    respond_with(@event)
  end

  def create
    params[:event]["creator_id"] = current_user.id.to_s
    @event.assign_attributes(params[:event], :as => as_what?)

    respond_with(@event) do |format|
      format.html do
        if can?(:manage, @event) && @event.save
          flash[:notice] = "Successfully created event #{@event.name}"
          redirect_to event_path(@event)
        else
          flash[:notice] = "SD: #{@event.start_datetime} ED: #{@event.end_datetime}"
          flash[:alert] = @event.errors.map{|attr, msg| "#{humanize(attr)} #{msg}"}.join("<br />")
          render :new
        end
      end
    end
  end

  def edit
    respond_with(@event)
  end

  def update
    respond_with(@event) do |format|
      format.html do
        if can?(:manage, @event) && @event.update_attributes(params[:event])
          flash[:notice] = "Successfully updated event #{@event.name}"
          redirect_to event_path(@event)
        else
          flash[:notice] = "SD: #{@event.start_datetime} ED: #{@event.end_datetime}"
          flash[:alert] = "Failed to update event #{@event.name}"
          redirect_to edit_event_path(@event)
        end
      end
    end
  end

  def destroy
    respond_with(@event) do |format|
      format.html do
        if can?(:manage, @event) && @event.destroy
          flash[:notice] = "Successfully destroyed event"
          redirect_to events_path
        else
          flash[:alert] = "Failed to destroy event #{@event.name}"
          render :show
        end
      end
    end
  end

  def carousel
    @event = Event.find(params[:event_id])
    if params[:checkin_id]
      time = @event.checkins.where(:id => params[:checkin_id]).first.created_at
      @checkins = @event.checkins.order(:created_at).where(:created_at => (time + 1.second)..Time.zone.now).limit(4)
    else
      @checkins = @event.checkins.order(:created_at).limit(4)
    end
    respond_with(@event) do |format|
      format.html

      format.json do
        render :json => @checkins.to_json(:only => [:id, :employer, :employ, :employment, :shoutout], :include => [:user => {:only => [:name]}])
      end
    end
  end

  def rafflr
    @event = Event.find(params[:event_id])
    @checkins = @event.checkins
    respond_with(@event) do |format|
      format.html
    end
  end
end
