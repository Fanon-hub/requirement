require 'rails_helper'

RSpec.describe 'Project Tasks access', type: :request do
  include Devise::Test::IntegrationHelpers

  before(:each) do
    @manager = User.create!(name: 'Manager', email: "pm+#{SecureRandom.hex(4)}@example.com", password: 'password')
    @project = Project.create!(name: 'Acme', description: 'x', status: :pending, project_manager: @manager, start_date: Date.today)
    @viewer = User.create!(name: 'Viewer', email: "viewer+#{SecureRandom.hex(4)}@example.com", password: 'password')
    ProjectMember.create!(project: @project, user: @viewer, role: 'viewer', joined_at: Date.today)
    @contributor = User.create!(name: 'Contributor', email: "contrib+#{SecureRandom.hex(4)}@example.com", password: 'password')
    ProjectMember.create!(project: @project, user: @contributor, role: 'contributor', joined_at: Date.today)
  end

  after(:each) do
    TaskComment.delete_all
    Task.delete_all
    ProjectMember.delete_all
    Project.delete_all
    Notification.delete_all
    User.delete_all
  end

  it 'prevents a viewer from accessing new task page' do
    sign_in @viewer
    get new_project_task_path(@project)

    expect(response).to redirect_to(project_path(@project))
  end

  it 'prevents a viewer from creating a task' do
    sign_in @viewer
    post project_tasks_path(@project), params: { task: { title: 'Blocked', status: :pending, priority: :low } }

    expect(response).to redirect_to(project_path(@project))
    expect(Task.where(title: 'Blocked')).to be_empty
  end

  it 'rejects creating a task with an assignee who is not a member' do
    outsider = User.create!(name: 'Outsider', email: 'out@example.com', password: 'password')
    sign_in @contributor

    post project_tasks_path(@project), params: { task: { title: 'Assign Bad', status: :pending, priority: :low, assignee_id: outsider.id } }

    expect(response.status).to eq(422)
    expect(Task.where(title: 'Assign Bad')).to be_empty
  end
end
