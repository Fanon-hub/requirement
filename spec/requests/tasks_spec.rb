require 'rails_helper'

RSpec.describe "Tasks", type: :request do
  describe "GET /index" do
    include Devise::Test::IntegrationHelpers

    it 'returns task index for a project when user is a member' do
      user = create(:user)
      project = create(:project, project_manager: user)
      ProjectMember.find_or_create_by!(project: project, user: user) do |pm|
        pm.role = 'manager'
        pm.joined_at = Date.today
      end
      sign_in user
      get project_tasks_path(project)
      expect([200,302]).to include(response.status)
    end
  end
end
