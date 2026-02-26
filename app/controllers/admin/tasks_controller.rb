class Admin::TasksController < Admin::BaseController
  before_action :set_task, only: [:show, :edit, :update, :destroy]

  def index
    @q     = Task.ransack(params[:q])
    @tasks = @q.result.includes(:project, :assignee, :creator).recent.page(params[:page]).per(20)
  end

  def show; end

  def edit
    @projects = Project.by_name
    @users    = User.by_name
  end

  def update
    if @task.update(task_params)
      redirect_to admin_tasks_path, notice: t('tasks.updated')
    else
      render :edit
    end
  end

  def destroy
    @task.destroy
    redirect_to admin_tasks_path, notice: t('tasks.deleted')
  end

  private

  def set_task
    @task = Task.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:title, :description, :status, :priority, :due_date, :assignee_id, :project_id)
  end
end