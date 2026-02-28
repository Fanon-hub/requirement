require 'rails_helper'

RSpec.describe "Pages", type: :request do
  describe "GET /index" do
    it 'returns the top page' do
      get root_path
      expect([200, 302]).to include(response.status)
    end
  end
end
