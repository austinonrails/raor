class UsersController < ApplicationController
  load_and_authorize_resource :user

  respond_to :html, :json

  def index
    respond_with(@users) do |format|
      format.html

      format.json do
        render :json => {:success => true, :total => @users.page(params[:page]).total_entries, :users => @users.page(params[:page]).as_json(:except => [:encrypted_password, :reset_password_token], :methods => :roles, :as => as_what?)}
      end
    end
  end

  def show
    respond_with(@user) do |format|
      format.html

      format.json do
        render :json => {:success => true, :users => @user.as_json(:except => [:encrypted_password, :reset_password_token], :methods => :roles, :as => as_what?)}
      end
    end
  end

  def new
    respond_with(@user)
  end

  def create
    if params[:users] && params[:users][0]
      @user.assign_attributes(params[:users][0])
      @user.roles = params[:users][0]['roles']
    end

    respond_with(@user) do |format|
      format.html do
        if @user.save
          flash[:notice] = "Successfully created user #{@user.name}"
          redirect_to user_path(@user)
        else
          flash[:error] = "Failed to create user #{@user.name}"
          redirect_to new_user_path
        end
      end

      format.json do
        if @user.save
          render :json => {:success => true, :users => [@user].as_json(:except => [:encrypted_password, :reset_password_token], :as => as_what?), :methods => :roles}
        else
          render :json => {:success => false}
        end
      end
    end
  end

  def edit
    responds_with(@user)
  end

  def update
    params[:users][0]["password"] = nil if params[:users] && params[:users][0] && params[:users][0]["password"].blank?

    respond_with(@user) do |format|
      format.html do
        if params[:user].blank?
          flash[:error] = "Error while trying to update user"
          redirect_to users_path
        elsif @user.update_attributes(params[:user])
          flash[:notice] = "Successfully updated user #{@user.name}"
          redirect_to user_path(@user)
        else
          flash[:error] = "Failed to update user #{@user.name}"
          redirect_to edit_user_path(@user)
        end
      end

      format.json do
        if params[:users].blank? || params[:users][0].blank?
          flash[:error] = "Error while trying to update user"
          render :json => {:success => false}
        elsif @user.update_attributes(params[:users][0]) && @user.save
          flash[:notice] = "Successfully updated user #{@user.name}"

          render :json => {:success => true, :users => [@user].as_json(:except => [:encrypted_password, :reset_password_token], :methods => :roles, :as => as_what?)}
        else
          flash[:error] = "Failed to update user #{@user.name}"
          render :json => {:success => false}
        end
      end
    end
  end

  def destroy
    @user.destroy unless @user.blank?

    respond_with(@user)
  end
end
