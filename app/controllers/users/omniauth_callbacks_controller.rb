class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def twitter
    @user = User.find_for_twitter_oauth(env["omniauth.auth"], current_user)
    if @user && @user.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Twitter"
      sign_in_and_redirect @user, :event => :authentication
    else
      if @user
        sign_in_and_redirect @user, :event => :authentication
      else
        flash[:alert] = "Unknown error while attempting to sign in via Twitter credentials"
        redirect_to new_user_session_path
      end
    end
  end

  def facebook
    @user = User.find_for_facebook_oauth(env["omniauth.auth"], current_user)
    if @user && @user.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Facebook"
      sign_in_and_redirect @user, :event => :authentication
    else
      if @user
        sign_in_and_redirect @user, :event => :authentication
      else
        flash[:alert] = "Unknown error while attempting to sign in via Facebook credentials"
        redirect_to new_user_session_path
      end
    end
  end

  def github
    @user = User.find_for_github_oauth(env["omniauth.auth"], current_user)
    if @user && @user.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Github"
      sign_in_and_redirect @user, :event => :authentication
    else
      if @user
        sign_in_and_redirect @user, :event => :authentication
      else
        flash[:alert] = "Unknown error while attempting to sign in via Github credentials"
        redirect_to new_user_session_path
      end
    end
  end

  def open_id
    @user = User.find_for_open_id(env["omniauth.auth"], current_user)
    if @user && @user.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "OpenID"
      sign_in_and_redirect @user, :event => :authentication
    else
      if @user
        sign_in_and_redirect @user, :event => :authentication
      else
        flash[:alert] = "Unknown error while attempting to sign in via OpenID credentials"
        session["devise.open:id_data"] = env["openid.ext1"]
        redirect_to new_user_session_path
      end
    end
  end

  def google
    # You need to implement the method below in your model
    @user = User.find_for_open_id(env["omniauth.auth"], current_user)
    if @user && @user.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Google"
      sign_in_and_redirect @user, :event => :authentication
    else
      if @user
        sign_in_and_redirect @user, :event => :authentication
      else
        flash[:alert] = "Unknown error while attempting to sign in via OpenID credentials"
        session["devise.google_data"] = request.env["omniauth.auth"]
        redirect_to new_user_session_path
      end
    end
  end
end
