require 'rails_helper'

RSpec.describe "Admin::Projects", type: :request do
  include Devise::Test::IntegrationHelpers
  describe "GET /index" do
    it 'returns admin projects index for admin user' do
      admin = create(:user, admin: true)
      sign_in admin
      get '/admin/projects'
      expect([200,302]).to include(response.status)
    end
  end
end
