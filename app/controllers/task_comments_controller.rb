class TaskCommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_task,    only: [:create]
  before_action :set_comment, only: [:destroy]
  before_action :authorize_comment!, only: [:destroy]

  def create
    @project = Project.find(params[:project_id])
    @task = @project.tasks.find(params[:task_id])
    @comment = @task.task_comments.build(task_comment_params)
    @comment.user = current_user

    if @comment.save
      redirect_to project_task_path(@project, @task),
                notice: t('task_comments.created') || "Comment posted successfully."
    else
    redirect_to project_task_path(@project, @task),
                alert: t('task_comments.create_failed') || "Failed to post comment."
    end
  end

  def destroy
    task = @comment.task
    @comment.destroy
    redirect_to project_task_path(task.project, task), notice: t('task_comments.deleted')
  end

  private

  def set_task
    @task = Task.find(params[:task_id])
  end

  def set_comment
    @comment = TaskComment.find(params[:id])
  end

  def authorize_comment!
    unless @comment.user == current_user || current_user.admin?
      redirect_to project_task_path(@comment.task.project, @comment.task), alert: t('errors.not_authorized')
    end
  end

  def task_comment_params
    params.require(:task_comment).permit(:comment_text)
  end
end