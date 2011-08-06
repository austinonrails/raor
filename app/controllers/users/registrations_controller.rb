class Users::RegistrationsController < Devise::RegistrationsController
  def new
    @provider = session["provider"]
    @uid = session["uid"]
    super
  end

  def create
    super
    user = User.find_by_email(params["user"]["email"])
    UserToken.create(:user => user, :uid => params["uid"], :provider => params["provider"])
  end

  def update
    super
  end
end