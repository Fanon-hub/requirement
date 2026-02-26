class Users::GuestSessionsController < ApplicationController
  def guest_login
    user = User.guest_user
    sign_in(user)
    redirect_to dashboard_path, notice: "Logged in as Guest"
  end

  def admin_guest_login
    user = User.admin_guest_user
    sign_in(user)
    redirect_to dashboard_path, notice: "Logged in as Admin Guest"
  end
end