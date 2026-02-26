class UserProjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project, only: [:show, :edit, :update, :destroy, :members, :add_member, :remove_member]
  before_action :authorize_project_manager!, only: [:edit, :update, :destroy, :add_member, :remove_member]

  def index
    @q        = Project.ransack(params[:q])
    @projects = @q.result.recent.page(params[:page]).per(9)
  end

  def show
    @tasks   = @project.tasks.includes(:assignee, :creator).by_due_date.page(params[:page]).per(10)
    @q       = @project.tasks.ransack(params[:q])
    @tasks   = @q.result.includes(:assignee, :creator).by_due_date.page(params[:page]).per(10)
    @members = @project.members.by_name
  end

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(project_params)
    @project.project_manager = current_user
    if @project.save
      ProjectMember.create!(project: @project, user: current_user, role: :manager, joined_at: Date.today)
      redirect_to @project, notice: t('projects.created')
    else
      render :new
    end
  end

  def edit; end

  def update
    if @project.update(project_params)
      redirect_to @project, notice: t('projects.updated')
    else
      render :edit
    end
  end

  def destroy
    @project.destroy
    redirect_to projects_path, notice: t('projects.deleted')
  end

  def members
    @members        = @project.project_members.includes(:user)
    @project_member = ProjectMember.new
    @available_users = User.where.not(id: @project.members.pluck(:id)).by_name
  end

  def add_member
  member_params = params.require(:project_member).permit(:user_id, :role)

  if member_params[:user_id].blank?
    redirect_to members_project_path(@project), alert: "Please select a user to add."
    return
  end

  user = User.find_by(id: member_params[:user_id])
  if user.nil?
    redirect_to members_project_path(@project), alert: "Selected user could not be found."
    return
  end

  if user == current_user
    redirect_to members_project_path(@project), alert: "You are already the project manager."
    return
  end

  if @project.users.exists?(user.id)
    redirect_to members_project_path(@project),
                alert: "#{user.display_name} is already a member of this project."
    return
  end

  # Now create using permitted params
  member = @project.project_members.build(
    user_id: user.id,          # or user: user
    role:    member_params[:role]&.to_sym   # safe conversion
  )

  if member.save
    redirect_to members_project_path(@project),
                notice: "#{user.display_name} has been added as #{member.role}."
  else
    redirect_to members_project_path(@project),
                alert: "Failed to add member: #{member.errors.full_messages.to_sentence}"
  end
end

  def remove_member
    member = @project.project_members.find_by!(user_id: params[:user_id])
    member.destroy
    redirect_to members_project_path(@project), notice: t('projects.member_removed')
  end

  private

  def set_project
    @project = Project.find(params[:id])
  end

  def authorize_project_manager!
    unless @project.project_manager == current_user || current_user.admin?
      redirect_to @project, alert: t('errors.not_authorized')
    end
  end

  def project_params
    params.require(:project).permit(:name, :description, :status, :start_date, :end_date)
  end
  private

  def member_params
    params.permit(:user_id, :role)
  end
end