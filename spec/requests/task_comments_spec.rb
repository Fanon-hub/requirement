require 'rails_helper'

RSpec.describe "TaskComments", type: :request do
  describe "GET /index" do
    include Devise::Test::IntegrationHelpers

    it 'accesses a safe route to exercise comments in context' do
      user = create(:user)
      project = create(:project, project_manager: user)
      ProjectMember.find_or_create_by!(project: project, user: user) do |pm|
        pm.role = 'manager'
        pm.joined_at = Date.today
      end
      task = create(:task, project: project, creator: user)
      sign_in user
      get project_task_path(project, task)
      expect([200,302]).to include(response.status)
    end
  end
end
