class UsersController < ApplicationController
  load_and_authorize_resource :user

  respond_to :html

  def index
    @users = @users.order(:name).page(params[:page])
    respond_with(@users)
  end

  def show
    respond_with(@user)
  end

  def new
    respond_with(@user)
  end

  def create
    respond_with(@user) do |format|
      format.html do
        if @user.save
          flash[:notice] = "Successfully created user #{@user.name}"
          redirect_to admin_users_path
        else
          flash[:alert] = "Failed to create user #{@user.name}"
          render :edit
        end
      end
    end
  end

  def edit
    respond_with(@user)
  end

  def update
    params[:user].delete(:password) if params[:user].has_key?(:password) && params[:user][:password].blank?
    params[:user].delete(:password_confirmation) if params[:user].has_key?(:password_confirmation) && params[:user][:password_confirmation].blank?

    respond_with(@user) do |format|
      format.html do
        if @user.update_attributes(params[:user])
          flash[:notice] = "Successfully updated user #{@user.name}"
          redirect_to admin_users_path
        else
          flash[:alert] = "Failed to update user #{@user.name}"
          redirect_to edit_admin_user_path(@user)
        end
      end
    end
  end

  def destroy
    respond_with(@user)  do |format|
      format.html do
        if @user.destroy
          flash[:notice] = "Successfully deleted user."
          redirect_to admin_users_path
        else
          flash[:alert] = "Error deleting user #{@user.name}."
          redirect_to admin_users_path
        end
      end
    end
  end
end
