class TaskCommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_task,    only: [:create]
  before_action :set_comment, only: [:destroy]
  before_action :authorize_comment!, only: [:destroy]

  def create
    @comment = @task.task_comments.build(comment_params)
    @comment.user = current_user
    if @comment.save
      redirect_to task_path(@task), notice: t('task_comments.created')
    else
      @comments = @task.task_comments.includes(:user).recent
      render 'tasks/show'
    end
  end

  def destroy
    task = @comment.task
    @comment.destroy
    redirect_to task_path(task), notice: t('task_comments.deleted')
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
      redirect_to task_path(@comment.task), alert: t('errors.not_authorized')
    end
  end

  def comment_params
    params.require(:task_comment).permit(:comment_text)
  end
end