require 'rails_helper'

RSpec.describe "Admin::Tasks", type: :request do
  include Devise::Test::IntegrationHelpers
  describe "GET /index" do
    it 'exposes an index action on the controller' do
      expect(Admin::TasksController.action_methods).to include('index')
    end
  end
end
