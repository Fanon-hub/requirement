require 'rails_helper'

RSpec.describe Project, type: :model do
  let(:manager) { create(:user) }

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(build(:project, project_manager: manager)).to be_valid
    end

    it 'is invalid without a name' do
      expect(build(:project, name: nil)).not_to be_valid
    end

    it 'is invalid with name over 100 characters' do
      expect(build(:project, name: 'a' * 101)).not_to be_valid
    end

    it 'is invalid when end_date is before start_date' do
      project = build(:project, start_date: Date.today, end_date: Date.yesterday)
      expect(project).not_to be_valid
      expect(project.errors[:end_date]).to be_present
    end

    it 'is valid when end_date equals start_date' do
      project = build(:project, start_date: Date.today, end_date: Date.today, project_manager: manager)
      expect(project).to be_valid
    end

    it 'is valid without dates' do
      project = build(:project, start_date: nil, end_date: nil, project_manager: manager)
      expect(project).to be_valid
    end
  end

  describe 'scopes' do
    let!(:active_project)    { create(:project, status: :in_progress,    project_manager: manager) }
    let!(:planning_project)  { create(:project, status: :pending,  project_manager: manager) }
    let!(:completed_project) { create(:project, status: :completed, project_manager: manager) }

    it '.active returns only active projects' do
      expect(Project.active).to include(active_project)
      expect(Project.active).not_to include(planning_project, completed_project)
    end

    it '.by_status filters by specific status' do
      expect(Project.by_status(:pending)).to include(planning_project)
      expect(Project.by_status(:pending)).not_to include(active_project)
    end

    it '.recent orders by created_at descending' do
      expect(Project.recent.first).to eq(completed_project)
    end
  end

  describe '#task_completion_rate' do
    it 'returns 0 when no tasks' do
      project = create(:project)
      expect(project.task_completion_rate).to eq(0)
    end

    it 'calculates percentage correctly' do
      project = create(:project)
      creator = create(:user)
      create(:task, project: project, creator: creator, status: :done)
      create(:task, project: project, creator: creator, status: :done)
      create(:task, project: project, creator: creator, status: :pending)
      create(:task, project: project, creator: creator, status: :pending)
      expect(project.task_completion_rate).to eq(50)
    end
  end
end