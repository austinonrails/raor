class ApplicationController < ActionController::Base
  include BrowserDetect
  before_filter :authenticate_user!
  protect_from_forgery
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end

  protected
  def as_what?
    klass = self.class.name.sub("Controller", "").underscore.split('/').last.singularize.camelize.constantize
    self.can?(:manage, klass) ? :admin : :default
  end
end
