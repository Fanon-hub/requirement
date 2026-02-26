class UserDashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @my_projects       = current_user.projects.includes(:tasks).recent.limit(6)
    @pending_tasks     = current_user.assigned_tasks.pending.by_due_date.includes(:project).limit(5)
    @in_progress_tasks = current_user.assigned_tasks.in_progress.includes(:project).limit(5)
    @overdue_tasks     = current_user.assigned_tasks.overdue.includes(:project)
    @notifications     = current_user.notifications.unread.recent
    @total_tasks       = current_user.assigned_tasks.count
    @done_count        = current_user.assigned_tasks.done.count
    @in_progress_count = current_user.assigned_tasks.in_progress.count
    @pending_count     = current_user.assigned_tasks.pending.count
    @completed_rate    = @total_tasks > 0 ? (@done_count.to_f / @total_tasks * 100).round : 0
  end
end