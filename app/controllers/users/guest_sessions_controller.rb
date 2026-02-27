class Users::GuestSessionsController < ApplicationController
  def guest_login
    user = User.guest_user
    sign_in(user)
    redirect_to dashboard_path, notice: "Logged in as Guest"
  end

  def admin_guest_login
    admin = AdminUser.admin_guest
    sign_in(:admin_user, admin)
    redirect_to admin_root_path 
  end
end 