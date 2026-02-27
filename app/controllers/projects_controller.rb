class ProjectsController < ApplicationController
  before_action :authenticate_user!

  before_action :set_project, only: %i[show edit update destroy members add_member remove_member]
  before_action :authorize_view_project,   only: [:show]
  before_action :authorize_manage_project, only: %i[edit update destroy add_member remove_member]

  def members
    @project = Project.find(params[:id])
    @members = @project.project_members.includes(:user)
    @project_member = @project.project_members.build
  end

  def add_member
    # @project is set via before_action set_project
    user_id = params.dig(:project_member, :user_id) || params[:user_id]
    role    = params.dig(:project_member, :role) || 'viewer'

    user = User.find(user_id)

    @project.project_members.create!(
      user: user,
      role: role,
      joined_at: Date.today
    )

    redirect_to members_project_path(@project), notice: "Member added successfully."
  end

  def remove_member
    @project = Project.find(params[:id])
    member = @project.project_members.find_by(user_id: params[:user_id])
    member.destroy if member 
    redirect_to members_project_path(@project), notice: "Member removed successfully."
  end

  def index
    @q = current_user.projects
                    .includes(:project_manager)
                    .ransack(params[:q])

    @projects = @q.result(distinct: true)
                    .order(created_at: :desc)
                    .page(params[:page])
                    .per(10)
    end

  def show
    @q = @project.tasks
                .includes(:assignee, :creator)
                .ransack(params[:q]) 
    @tasks = @q.result(distinct: true)
                .order(due_date: :asc, created_at: :desc)
                .page(params[:page])
                .per(10)

    @members = @project.project_members
                        .includes(:user)
                        .references(:users)
                        .order('users.name ASC')
    end  

  def new
    @project = Project.new
  end

  def create
    @project = current_user.managed_projects.build(project_params)
    @project.project_manager = current_user

    if @project.save
        redirect_to @project, notice: t('projects.created_successfully')
    else
        render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @project.update(project_params)
      redirect_to @project, notice: t('projects.updated_successfully')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @project.destroy
    redirect_to projects_path, notice: t('projects.deleted_successfully')
  end

  private

  def set_project
    @project = current_user.projects.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to projects_path, alert: t('errors.project_not_found_or_no_access')
  end

  def authorize_view_project
    # This is now mostly redundant because set_project already filters,
    # but keeping it for explicitness & future-proofing
    unless current_user.can_view_project?(@project)
      redirect_to projects_path, alert: t('errors.not_a_member_of_this_project')
    end
  end

  def authorize_manage_project
    unless current_user.can_manage_project?(@project)
      redirect_to project_path(@project), alert: t('errors.only_managers_can_modify_project')
    end
  end

  def project_params
    params.require(:project).permit(
        :name,
        :description,
        :status,
        :start_date,
        :end_date
    )
    end
end