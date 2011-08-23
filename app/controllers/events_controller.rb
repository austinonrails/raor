class EventsController < ApplicationController
  load_and_authorize_resource :except => [:index, :current]  
  before_filter :authenticate_user!

  def index
    # Must manually authorize due to setting current_user on events
    if can?(:read, Event) && can?(:read, User)
      respond_to do |format|
        format.html do
          if browser_is?("webkit")
            render :nothing => true, :layout => true
          else
            @events = Event.all
            render :index
          end
        end

        format.json do
          events = Event.page(params[:page])
          events.map{|event| event.current_user = current_user}
          render :json => {:success => true, :total => events.total_entries, :events => events.as_json(:include => {:creator => {:only => "name"}}, :methods => :is_checked_in?)}
        end
      end
    end
  end

  def current
     # Must manually authorize due to setting current_user on events
    if can?(:read, Event) && can?(:read, User)
      event = Event.current.first
      respond_to do |format|
        format.html do
          if event
            redirect_to event_path(event)
          else
            redirect_to events_path
          end
        end

        format.json do
          events = Event.page(params[:page])
          events.map{|event| event.current_user = current_user}
          render :json => {:success => true, :total => events.total_entries, :events => events.as_json(:include => {:creator => {:only => "name"}}, :methods => :is_checked_in?)}
        end
      end
    end
  end

  def show
    @event = Event.find(params[:id])

    respond_to do |format|
      format.html do
        if browser_is?("webkit")
          redirect_to events_path(:current_event => @event)
        else
          render :index
        end
      end
    end
  end

  def new
    @event = Event.new
  end

  def create
    params[:event][:creator_id] = current_user.id
    @event = Event.create(params[:event])

    respond_to do |format|
      format.html do
        if @event
          flash[:notice] = "Successfully created event #{@event.name}"
          redirect_to event_path(@event)
        else
          flash[:error] = "Failed to create event #{@event.name}"
          redirect_to new_event_path
        end
      end

      format.json do
        if @event
          render :json => {:success => true}
        else
          render :json => {:success => false}
        end
      end
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
