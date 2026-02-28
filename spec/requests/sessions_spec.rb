require 'rails_helper'

RSpec.describe "Sessions", type: :request do
  describe "GET /index" do
    it 'renders new session (login) page' do
      get new_user_session_path
      expect(response.status).to eq(200)
    end
  end
end
