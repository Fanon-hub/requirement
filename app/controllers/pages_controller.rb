class PagesController < ApplicationController
  before_action :authenticate_user!, except: [:top]

  before_action only: [:top] do
    redirect_to dashboard_path if user_signed_in?
  end
end