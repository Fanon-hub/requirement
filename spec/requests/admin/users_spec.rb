require 'rails_helper'

RSpec.describe "Admin::Users", type: :request do
  include Devise::Test::IntegrationHelpers
  describe "GET /index" do
    it 'exposes an index action on the controller' do
      expect(Admin::UsersController.action_methods).to include('index')
    end
  end
end
