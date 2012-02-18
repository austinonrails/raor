class CheckinsController < ApplicationController
  load_and_authorize_resource :event
  load_and_authorize_resource :checkin, :through => :event

  respond_to :html

  def index
    case as_what?
      when :admin
      else
        @checkins = Checkin.unhidden
    end

    respond_with(@event, @checkins)
  end

  def show
    respond_with(@checkin)
  end

  def new
    @checkin.current_user = current_user
    @checkin.employer = @checkin.current_user.employer if @checkin.remember_employer
    respond_with(@checkin)
  end

  def create
    respond_with(@event, @checkin) do |format|
      @checkin.assign_attributes(params[:checkin], :as => as_what?)
      @checkin.user_id = current_user.id
      @checkin.current_user = current_user
      @checkin.event_id = @event.id

      format.html do
        if @checkin.save
          flash[:notice] = "Successfully checked in to #{@event.name}"
          redirect_to event_path(@event)
        else
          flash[:error] = "Failed to check in to #{@event.name}"
          redirect_to event_path(@event)
        end
      end
    end
  end

  def edit
    @checkin.current_user = current_user
    respond_with(@checkin)
  end

  def update
    @checkin.current_user = current_user
    respond_with(@event, @checkin) do |format|
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
    end
  end

  def destroy
    respond_with(@event, @checkin) do |format|
      name = @checkin.current_user.name if @checkin.current_user

      format.html do
        if @checkin.destroy
          flash[:notice] = "Successfully destroyed checkin for #{name}"
          redirect_to event_path(@event)
        else
          flash[:error] = "Failed to destroy checkin for #{name}"
        end
      end
    end
  end
end