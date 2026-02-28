require 'rails_helper'

RSpec.describe "Errors", type: :request do
  describe "GET /index" do
    it 'renders the 404 page (or returns 200 in dev-like env)' do
      get '/404'
      expect([200,404]).to include(response.status)
    end
  end
end
