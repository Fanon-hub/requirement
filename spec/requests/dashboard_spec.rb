require 'rails_helper'

RSpec.describe "Dashboards", type: :request do
  describe "GET /index" do
    include Devise::Test::IntegrationHelpers

    it 'returns dashboard for signed-in user' do
      user = create(:user)
      sign_in user
      get dashboard_path
      expect([200,302]).to include(response.status)
    end
  end
end
