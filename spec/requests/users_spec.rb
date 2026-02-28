require 'rails_helper'

RSpec.describe "Users", type: :request do
  describe "GET /index" do
    include Devise::Test::IntegrationHelpers

    it 'shows a user profile' do
      user = create(:user)
      sign_in user
      get user_path(user)
      expect([200,302]).to include(response.status)
    end
  end
end
