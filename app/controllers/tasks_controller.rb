class TasksController < ApplicationController
  before_action :authenticate_user!

  before_action :set_project, only: %i[index new create edit update destroy update_status show]
  before_action :set_task,    only: %i[edit update destroy update_status show]

  before_action :authorize_project_member, only: %i[index new create edit update destroy update_status show]
  before_action :authorize_contributor,    only: %i[new create edit update update_status]
  before_action :authorize_delete,         only: :destroy

  def index
    @q = @project.tasks.ransack(params[:q])
    @tasks = @q.result(distinct: true)
               .includes(:assignee, :creator)
               .order(due_date: :asc, created_at: :desc)
               .page(params[:page]).per(20)
  end

  def show
    @comment  = @task.task_comments.build
    @comments = @task.task_comments.includes(:user).order(created_at: :desc)
  end

  def new
    @task = @project.tasks.new
    @assignees = @project.users.order(:name)
  end

  def create
    @task = @project.tasks.build(task_params)
    @task.creator = current_user

    if @task.save
      notify_assignee(@task) if @task.assignee.present?
      redirect_to project_tasks_path(@project), notice: t('tasks.created_successfully')
    else
      @assignees = @project.users.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @assignees = @project.users.order(:name)
  end

  def update
    if @task.update(task_params)
      notify_assignee(@task) if @task.assignee_id_previously_changed? && @task.assignee.present?
      redirect_to project_task_path(@project, @task), notice: t('tasks.updated_successfully')
    else
      @assignees = @project.users.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @task.destroy
    redirect_to project_path(@project), notice: t('tasks.deleted_successfully')
  end

  def update_status
    if @task.update(status: params[:status])
      redirect_back fallback_location: project_task_path(@project, @task),
                    notice: t('tasks.status_updated')
    else
      redirect_back fallback_location: project_task_path(@project, @task),
                    alert: t('tasks.status_update_failed')
    end
  end

  private

  def set_project
    @project = current_user.projects.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to projects_path, alert: t('errors.project_not_found_or_access_denied')
  end

  def set_task
    @task = @project.tasks.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to project_tasks_path(@project), alert: t('errors.task_not_found')
  end

  def authorize_project_member
    unless current_user.can_view_project?(@project)
      redirect_to projects_path, alert: t('errors.access_denied')
    end
  end

  def authorize_contributor
    unless current_user.can_contribute_to?(@project)
      redirect_to project_path(@project), alert: t('errors.no_permission_to_modify_tasks')
    end
  end

  def authorize_delete
    unless current_user.can_delete_task?(@task)
      redirect_to project_task_path(@project, @task), alert: t('errors.only_managers_can_delete_tasks')
    end
  end

  def task_params
    params.require(:task).permit(
      :title,
      :description,
      :priority,
      :due_date,
      :assignee_id    
    )
  end

  def notify_assignee(task)
    return unless task.assignee && task.assignee != current_user

    Notification.create!(
      user: task.assignee,
      notification_type: 'task_assigned',
      message: t('notifications.task_assigned', task_title: task.title)
    )
  rescue StandardError => e
    Rails.logger.error "Notification creation failed: #{e.message}"
  end
end