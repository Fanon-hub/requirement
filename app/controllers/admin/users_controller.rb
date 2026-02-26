class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def index
    @q     = User.ransack(params[:q])
    @users = @q.result.order(:name).page(params[:page]).per(20)
  end

  def show; end

  def edit; end

  def update
    if @user.update(user_params)
      redirect_to admin_users_path, notice: t('admin.users.updated')
    else
      render :edit
    end
  end

  def destroy
    if @user == current_user
      redirect_to admin_users_path, alert: t('admin.users.cannot_delete_self')
    else
      @user.destroy
      redirect_to admin_users_path, notice: t('admin.users.deleted')
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email, :admin)
  end
end