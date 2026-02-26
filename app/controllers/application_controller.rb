class ApplicationController < ActionController::Base
  include Pundit::Authorization

  before_action :set_locale
  before_action :set_notifications, if: :user_signed_in?

  private
  
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  
  def user_not_authorized
    redirect_to root_path, alert: t('errors.not_authorized')
  end

  def set_locale
    I18n.locale = :en
  end

  def set_notifications
    @unread_notifications_count = current_user.notifications.unread.count
  end

  
  def require_admin!
    unless current_user&.admin?
      redirect_to root_path, alert: t('errors.not_authorized')
    end
  end

  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end

  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end
end