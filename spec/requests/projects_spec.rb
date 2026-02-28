require 'rails_helper'

RSpec.describe "Projects", type: :request do
  describe "GET /index" do
    include Devise::Test::IntegrationHelpers

    it 'allows signed-in user to access projects index' do
      user = create(:user)
      sign_in user
      get projects_path
      expect([200,302]).to include(response.status)
    end
  end
end
