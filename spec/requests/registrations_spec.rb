require 'rails_helper'

RSpec.describe "Registrations", type: :request do
  describe "GET /index" do
    it 'renders new registration page' do
      get new_user_registration_path
      expect(response.status).to eq(200)
    end
  end
end
