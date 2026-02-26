class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = current_user.notifications.recent
  end

  def mark_read
    notification = current_user.notifications.find(params[:id])
    notification.update(is_read: true)
    redirect_back fallback_location: notifications_path
  end

  def mark_all_read
    current_user.notifications.unread.update_all(is_read: true)
    redirect_to notifications_path, notice: t('notifications.all_marked_read')
  end
end