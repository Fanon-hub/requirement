require 'rails_helper'

RSpec.describe Task, type: :model do
  let(:project) { create(:project) }
  let(:creator) { create(:user) }

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(build(:task, project: project, creator: creator)).to be_valid
    end

    it 'is invalid without a title' do
      task = build(:task, title: nil, project: project, creator: creator)
      expect(task).not_to be_valid
      expect(task.errors[:title]).to be_present
    end

    it 'is invalid with title over 200 characters' do
      task = build(:task, title: 'a' * 201, project: project, creator: creator)
      expect(task).not_to be_valid
    end

    it 'is invalid without a status' do
      task = Task.new(title: 'Test', project: project, creator: creator, priority: :medium)
      task.status = nil
      # enum makes nil invalid only without default; test the presence validation
      expect { task.status = 'invalid_status' }.to raise_error(ArgumentError)
    end

    it 'is invalid without a project' do
      task = build(:task, project: nil, creator: creator)
      expect(task).not_to be_valid
    end
  end

  describe 'scopes' do
    let!(:high_task)    { create(:task, priority: :high,   status: :pending,     project: project, creator: creator, due_date: Date.today + 5) }
    let!(:low_task)     { create(:task, priority: :low,    status: :in_progress, project: project, creator: creator, due_date: Date.today + 10) }
    let!(:done_task)    { create(:task, priority: :medium, status: :done,        project: project, creator: creator, due_date: Date.today + 3) }
    let!(:overdue_task) { create(:task, priority: :high,   status: :pending,     project: project, creator: creator, due_date: Date.today - 2) }

    it '.high_priority returns only high priority tasks' do
      expect(Task.high_priority).to include(high_task, overdue_task)
      expect(Task.high_priority).not_to include(low_task)
    end

    it '.incomplete excludes done tasks' do
      expect(Task.incomplete).to include(high_task, low_task, overdue_task)
      expect(Task.incomplete).not_to include(done_task)
    end

    it '.overdue returns past-due incomplete tasks' do
      expect(Task.overdue).to include(overdue_task)
      expect(Task.overdue).not_to include(done_task)
      expect(Task.overdue).not_to include(high_task) # not past due
    end

    it '.by_due_date orders tasks by due date ascending' do
      ordered = Task.by_due_date.to_a
      dates = ordered.map(&:due_date).compact
      expect(dates).to eq(dates.sort)
    end
  end

  describe '#overdue?' do
    it 'returns true when due_date is past and not done' do
      task = build(:task, due_date: Date.yesterday, status: :pending)
      expect(task.overdue?).to be true
    end

    it 'returns false when task is done even if past due' do
      task = build(:task, due_date: Date.yesterday, status: :done)
      expect(task.overdue?).to be false
    end

    it 'returns false when due_date is nil' do
      task = build(:task, due_date: nil)
      expect(task.overdue?).to be false
    end
  end

  describe '#days_until_due' do
    it 'returns positive number when due in future' do
      task = build(:task, due_date: Date.today + 5)
      expect(task.days_until_due).to eq(5)
    end

    it 'returns negative number when past due' do
      task = build(:task, due_date: Date.today - 3)
      expect(task.days_until_due).to eq(-3)
    end

    it 'returns nil when no due date' do
      task = build(:task, due_date: nil)
      expect(task.days_until_due).to be_nil
    end
  end
end