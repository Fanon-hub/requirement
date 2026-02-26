class UserTasksController < ApplicationController

  before_action :authenticate_user!

  before_action :set_project, only: %i[index new create edit update show]
  before_action :set_task,    only: %i[show edit update update_status destroy]
  
  before_action :authorize_view_task!,   only: %i[index show]
  before_action :authorize_manage_task!, only: %i[edit update destroy]
  before_action :authorize_change_status!, only: :update_status

  def index
    @q     = policy_scope(@project.tasks).ransack(params[:q])
    @tasks = @q.result.includes(:assignee, :creator).by_due_date.page(params[:page]).per(15)
  rescue Pundit::NotAuthorizedError
    @tasks = @project.tasks.none
    flash.now[:alert] = "Authorization not configured for tasks." 
  end

  def show
    @comment  = TaskComment.new
    @comments = @task.task_comments.includes(:user).recent
  end

  def new
    @task = @project.tasks.build
  end

  def set_project
    @project = current_user.projects.find(params[:project_id])
  end


  def create
    @project = Project.find(params[:project_id]) 
    @task = @project.tasks.build(task_params)
    @task.creator = current_user

    if @task.save
      redirect_to project_tasks_path(@project), notice: "Task was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @task.update(task_params)
      notify_assignee(@task) if @task.assignee_id_previously_changed? && @task.assignee.present?
      redirect_to project_task_path(project_id: @project.id, id: @task.id), notice: t('tasks.updated')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @task.destroy
    respond_to do |format|
      format.html { redirect_to project_path(@task.project), notice: "Task was successfully deleted." }
      format.json { head :no_content }
    end
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.html { redirect_to projects_path, alert: "Task not found." }
      format.json { render json: { error: "Not found" }, status: :not_found }
    end
  end

  def update_status
    if @task.update(status: params[:status])
      redirect_back fallback_location: @task, notice: t('tasks.status_updated')
    else
      redirect_back fallback_location: @task, alert: t('tasks.status_update_failed')
    end
  end

  
  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_task
    @task = Task.find(params[:id])
  end

  
  def authorize_view_task!
    return redirect_to projects_path, alert: t('errors.not_authorized') unless @project

    unless current_user.projects.exists?(@project.id)
      redirect_to projects_path, alert: t('errors.not_authorized') and return
    end 
  end


  def authorize_manage_task!
    unless @task.creator == current_user || current_user.admin?
      redirect_to project_task_path(@task.project, @task), alert: t('errors.not_authorized') and return
    end
  end

  def authorize_change_status!
    unless @task.assignee == current_user || @task.creator == current_user || current_user.admin?
      redirect_back fallback_location: @task, alert: t('errors.not_authorized') and return
    end
  end

  def notify_assignee(task)
    return unless task&.assignee

    Notification.create_for(
      task.assignee,
      'task_assigned',
      t('notifications.task_assigned', task_title: task.title)
    )
  rescue StandardError => e
    Rails.logger.error "Notification failed: #{e.message}"
  end

  def task_params
    params.require(:task).permit(
      :title, :description, :status, :priority, :due_date, :assignee_id
    )
  end
end