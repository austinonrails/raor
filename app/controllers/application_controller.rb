class ApplicationController < ActionController::Base
  include BrowserDetect
  before_filter :authenticate_user!
  before_filter :init_history
  after_filter :add_history

  protect_from_forgery
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end

  protected
  def as_what?
    klass = self.class.name.sub("Controller", "").underscore.split('/').last.singularize.camelize.constantize
    self.can?(:manage, klass) ? :admin : :default
  end

  private
  def add_history
    [/\/edit$/].each do |regex|
      return if request.env['REQUEST_PATH'] =~ regex
    end
    unless request.env['REQUEST_PATH'][0..11] == "/users/auth/" || !session.has_key?(:history) || request.env['REQUEST_PATH'] == session[:history].last
      session[:history].push(request.env['REQUEST_PATH'])
    end
  end

  def init_history
    session[:history] = [] if request.env['REQUEST_PATH'] == '/' || request.env['HTTP_REFERER'].blank?
  end
end
