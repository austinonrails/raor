class EventsController < ApplicationController
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

        format.json do
          render :json => {:success => true, :total => @events.total_entries, :events => @events.as_json(:include => {:creator => {:only => "name"}}, :methods => :is_checked_in, :as => as_what?)}
        end
      end
    end
  end

  def show
    @event.current_user = current_user

    respond_with(@event) do |format|
      format.html do
        render
      end

      format.json do
        render :json => {:success => true, :events => @event.as_json(:include => {:creator => {:only => "name"}}, :methods => :is_checked_in, :as => as_what?)}
      end
    end
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
          flash[:error] = "Failed to create event #{@event.name}"
          render :edit
        end
      end

      format.json do
        if can?(:manage, @event) && @event.save
          render :json => {:success => true, :events => [@event.as_json(:include => {:creator => {:only => "name"}}, :methods => :is_checked_in, :as => as_what?)]}
        else
          render :json => {:success => false, :events => [], :errors => @event.errors}
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
          flash[:error] = "Failed to update event #{@event.name}"
          render :edit
        end
      end

      format.json do
        if can?(:manage, @event) && @event.update_attributes(params[:events].first)
          render :json => {:success => true, :events => [@event.as_json(:include => {:creator => {:only => "name"}}, :methods => :is_checked_in, :as => as_what?)]}
        else
          render :json => {:succes => false, :events => [], :errors => @event.errors}
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
          flash[:error] = "Failed to destroy event #{@event.name}"
          render :show
        end
      end

      format.json do
        if can?(:manage, @event) && @event.destroy
          render :json => {:success => true, :events => []}
        else
          render :json => {:success => false, :events => [], :errors => @event.errors}
        end
      end
    end
  end
end
