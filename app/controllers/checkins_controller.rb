class CheckinsController < ApplicationController
  load_and_authorize_resource :event
  load_and_authorize_resource :checkin, :through => :event

  respond_to :html, :json

  def index
    case as_what?
      when :admin
      else
        @checkins = Checkin.unhidden
    end

    ActiveSupport::JSON.decode(params[:filter]).each do |filter|
      case filter["property"]
        when "employ"
          @checkins = @checkins.where(:employ => true)
        when "employment"
          @checkins = @checkins.where(:employment => true)
      end
    end if params[:filter].present?

    respond_with(@checkins) do |format|
      format.json do
        render :json => {:success => true, :total => @checkins.page(params[:page]).total_entries, :checkins => @checkins.page(params[:page]).as_json(:include => {:user => {:only => :name}}, :as => as_what?)}
      end
    end
  end

  def show
    respond_with(@checkin) do |format|
      format.json do
        render :json => {:success => true, :checkin => @checkin.as_json(:include => {:user => {:only => :name}}, :as => as_what?)}
      end
    end
  end

  def new
    respond_with(@checkin)
  end

  def create
    respond_with(@checkin) do |format|
      @checkin.assign_attributes(params[:checkins].first, :as => as_what?)
      @checkin.user_id = current_user.id
      @checkin.current_user = current_user
      @checkin.event_id = @event.id
      format.html do
        if @checkin.save
          flash[:notice] = "Successfully checked in to event #{event.name}"
          redirect_to edit_checkin_path(checkin)
        else
          flash[:error] = "Failed to check in to event #{event.name}"
          redirect_to new_event_path
        end
      end

      format.json do
        if @checkin.save
          render :json => {:success => true, :checkins => [@checkin.as_json(:include => {:user => {:only => "name"}}, :as => as_what?)]}
        else
          render :json => {:success => false, :errors => @checkin.errors, :checkins => []}
        end
      end
    end
  end

  def edit
    respond_with(@checkin)
  end

  def update
    @checkin.current_user = current_user
    respond_with(@checkin) do |format|
      format.html do
        if params[:checkin]
          if @checkin.update_attributes(params[:checkin])
            flash[:notice] = "Successfully updated checkin status for #{@checkin.event.name}"
            redirect_to event_path(@checkin.event)
          else
            flash[:error] = "Failed to update checkin status"
            redirect_to new_event_path
          end
        else
          if @event && @checkin.save
            flash[:notice] = "Successfully checked in to event #{@event.name}"
            redirect_to event_path(@event)
          else
            flash[:error] = "Failed to check in to event #{@event.name}"
            redirect_to new_event_path
          end
        end
      end

      format.json do
        if can?(:manage, @event) && @checkin.update_attributes(params[:checkins].first, :as => as_what?)
          render :json => {:success => true, :checkins => [@checkin.as_json(:include => {:user => {:only => "name"}}, :as => as_what?)]}
        else
          render :json => {:success => false, :errors => @checkin.errors, :checkins => []}
        end
      end
    end
  end

  def destroy
    respond_with(@checkin) do |format|
      format.json do
        if @checkin.destroy
          render :json => {:success => true, :checkins => []}
        else
          render :json => {:success => false, :checkins => []}          
        end
      end
    end
  end
end
