class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def twitter
    @user = User.find_for_twitter_oauth(env["omniauth.auth"], current_user)
    if !@user
      session["provider"] = env["omniauth.auth"]["provider"]
      session["uid"] = env["omniauth.auth"]["uid"]
      redirect_to new_user_registration_url
    elsif @user.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Twitter"
      sign_in_and_redirect @user, :event => :authentication
    else
      session["provider"] = env["omniauth.auth"]["provider"]
      session["uid"] = env["omniauth.auth"]["uid"]
      redirect_to new_user_registration_url
    end
  end
end
