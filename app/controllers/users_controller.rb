class UsersController < ApplicationController
  load_and_authorize_resource
  before_filter :authenticate_user!

  def index
    users = User.all
    users.each do |user|
      user.accessible = [:id,:email,:reset_password_sent_at,:remember_created_at,:sign_in_count,:current_sign_in_at,:last_sign_in_at,:current_sign_in_ip,:last_sign_in_ip,:name,:created_at,:updated_at]
    end if can? :manage, User

    respond_to do |format|
      format.html

      format.json do
        render :json => {:success => true, :users => users.as_json(:except => [:encrypted_password, :reset_password_token], :methods => :roles)}
      end
    end
  end

  def show
    @users = User.find(params[:id])

    respond_to do |format|
      format.html

      format.json do
        render :json => {:success => true, :users => users.as_json(:except => [:encrypted_password, :reset_password_token], :methods => :roles)}
      end
    end
  end

  def new
    @user = User.new
  end

  def create
    if params[:users] && params[:users][0]
      @user = User.new(params[:users][0])
      @user.roles = params[:users][0]['roles']
      @user.accessible = [:id,:email,:reset_password_sent_at,:remember_created_at,:sign_in_count,:current_sign_in_at,:last_sign_in_at,:current_sign_in_ip,:last_sign_in_ip,:name,:created_at,:updated_at] if can? :manage, User
      @user.save
    end

    respond_to do |format|
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
          render :json => {:success => true, :users => [@user].as_json(:except => [:encrypted_password, :reset_password_token]), :methods => :roles}
        else
          render :json => {:success => false}
        end
      end
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    params[:users][0]["password"] = nil if params[:users] && params[:users][0] && params[:users][0]["password"].blank?
    @user = User.find(params[:id])
    @user.roles = params[:users][0]['roles']
    @user.accessible = [:id,:email,:reset_password_sent_at,:remember_created_at,:sign_in_count,:current_sign_in_at,:last_sign_in_at,:current_sign_in_ip,:last_sign_in_ip,:name,:created_at,:updated_at] if can? :manage, User

    respond_to do |format|
      format.html do
        if params[:user].blank?
          flash[:error] = "Error while trying to update user"
          redirect_to users_path
        elsif @user.update_attributes(params[:user]) && @user.save
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

          render :json => {:success => true, :users => [@user].as_json(:except => [:encrypted_password, :reset_password_token], :methods => :roles)}
        else
          flash[:error] = "Failed to update user #{@user.name}"
          render :json => {:success => false}
        end
      end
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy unless @user.blank?
  end
end
