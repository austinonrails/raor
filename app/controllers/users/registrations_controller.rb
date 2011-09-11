class Users::RegistrationsController < Devise::RegistrationsController
  def new
    @provider = session["provider"]
    @uid = session["uid"]
    super
  end

  def create
    super
    User.find_by_email(params[:user][:email]) || User.create(params[:user])
  end

  def update
    super
  end
end