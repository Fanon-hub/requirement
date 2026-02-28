require 'rails_helper'

RSpec.describe "Notifications", type: :request do
  describe "GET /index" do
    include Devise::Test::IntegrationHelpers

    it 'returns notifications for signed-in user' do
      user = create(:user)
      create(:notification, user: user)
      sign_in user
      get notifications_path
      expect(response.status).to eq(200)
    end
  end
end
