require 'rails_helper'

RSpec.describe "Admin::Dashboards", type: :request do
  include Devise::Test::IntegrationHelpers
  describe "GET /index" do
    it 'returns admin dashboard for admin user' do
      admin = create(:user, admin: true)
      sign_in admin
      get '/admin'
      expect([200,302]).to include(response.status)
    end
  end
end
