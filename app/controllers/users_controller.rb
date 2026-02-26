class UsersController < ApplicationController
  before_action :authenticate_user!, only: [:show, :edit, :update]
  before_action :set_user, only: [:show, :edit, :update]
  before_action :correct_user!, only: [:edit, :update]

  def new
    redirect_to dashboard_path if logged_in?
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in(@user)
      redirect_to dashboard_path, notice: t('users.created')
    else
      render :new
    end
  end

  def show
    @projects = @user.projects.recent.limit(5)
    @tasks    = @user.assigned_tasks.incomplete.by_due_date.limit(5)
  end

  def edit; end

  def update
    if @user.update(user_params)
      redirect_to user_path(@user), notice: t('users.updated')
    else
      render :edit
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def correct_user!
    redirect_to root_path, alert: t('errors.not_authorized') unless @user == current_user
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end