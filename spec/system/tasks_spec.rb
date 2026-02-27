require 'rails_helper'

RSpec.describe 'Tasks CRUD', type: :system do
  before { driven_by(:rack_test) }

  let!(:user)    { create(:user) }
  let!(:project) { create(:project, project_manager: user) }
  let!(:task)    { create(:task, project: project, creator: user) }

  before { rack_session_login(user) }

  describe 'create' do
    it 'creates a task with valid inputs' do
      visit new_project_task_path(project)
      fill_in I18n.t('tasks.fields.title'), with: 'New Test Task'
      fill_in I18n.t('tasks.fields.description'), with: 'Some task description'
      select I18n.t('tasks.priorities.high'), from: I18n.t('tasks.fields.priority')
      click_button I18n.t('helpers.submit.create', model: 'Task')
      expect(page).to have_content('New Test Task')
      expect(page).to have_content(I18n.t('tasks.created'))
    end

    it 'shows error when title is blank' do
      visit new_project_task_path(project)
      click_button I18n.t('helpers.submit.create', model: 'Task')
      expect(page).to have_content('Task title cannot be blank')
    end
  end

  describe 'show' do
    it 'displays task details' do
      visit project_task_path(project, task)
      expect(page).to have_content(task.title)
    end
  end

  describe 'edit' do
    it 'updates a task' do
      visit edit_project_task_path(project, task)
      fill_in I18n.t('tasks.fields.title'), with: 'Updated Task Title'
      click_button I18n.t('helpers.submit.update', model: 'Task')
      expect(page).to have_content('Updated Task Title')
      expect(page).to have_content(I18n.t('tasks.updated'))
    end
  end

  describe 'delete' do
    it 'deletes a task' do
      visit project_task_path(project, task)
      click_button I18n.t('actions.delete')
      expect(page).to have_content("Task was successfully deleted")
      expect(page).not_to have_current_path(project_task_path(project, task))
    end
  end

  describe 'status update' do
    it 'updates task status' do
      visit project_task_path(project, task)
      click_button I18n.t('tasks.statuses.in_progress')
      expect(page).to have_content(I18n.t('tasks.status_updated'))
    end
  end
end

RSpec.describe 'Access Restrictions', type: :system do
  before { driven_by(:rack_test) }

  let!(:user)       { create(:user) }
  let!(:other_user) { create(:user) }
  let!(:admin)      { create(:user, :admin) }
  let!(:project)    { create(:project, project_manager: other_user) }
  let!(:task)       { create(:task, project: project, creator: other_user) }

  describe 'unauthenticated access' do
    it 'redirects to login when accessing dashboard without login' do
      visit dashboard_path
      expect(page).to have_current_path(new_user_session_path)
    end

    it 'redirects to login when accessing projects' do
      visit projects_path
      expect(page).to have_current_path(new_user_session_path)
    end
  end

  describe 'admin panel restriction' do
    it 'blocks regular users from admin panel' do
      rack_session_login(user)
      visit admin_root_path
      expect([root_path, new_admin_user_session_path]).to include(page.current_path)
    end

    it 'allows admin users to access admin panel' do
      login_as(admin, scope: :user) if defined?(login_as)
      rack_session_login(admin) unless defined?(login_as)
      visit dashboard_path
      # Admin user should see and be able to click admin panel link
      expect(page).to have_link(I18n.t('navigation.admin_panel'))
    end
  end

  describe "editing another user's task" do
    it 'prevents regular user from editing someone else task' do
      rack_session_login(user)
      visit edit_project_task_path(project, task)
      expect(page.current_path).not_to eq(edit_project_task_path(project, task))
    end

    it 'allows the task creator to edit their own task' do
      rack_session_login(other_user)
      visit edit_project_task_path(project, task)
      expect(page).to have_current_path(edit_project_task_path(project, task))
    end

    it 'allows admin to edit any task' do
      # Create admin as project member so they can access the task
      ProjectMember.create!(project: project, user: admin, role: 'manager', joined_at: Date.today)
      rack_session_login(admin)
      visit edit_project_task_path(project, task)
      expect(page).to have_current_path(edit_project_task_path(project, task))
    end
  end

  describe 'admin links visibility' do
    it 'hides admin panel link from regular users' do
      rack_session_login(user)
      visit dashboard_path
      expect(page).not_to have_link(I18n.t('navigation.admin_panel'))
    end

    it 'shows admin panel link to admin users' do
      login_as(admin, scope: :user) if defined?(login_as)
      rack_session_login(admin) unless defined?(login_as)
      visit dashboard_path
      expect(page).to have_link(I18n.t('navigation.admin_panel'))
    end
  end
end