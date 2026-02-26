require 'rails_helper'

RSpec.describe 'Projects CRUD', type: :system do
  before { driven_by(:rack_test) }

  let!(:user)    { create(:user) }
  let!(:project) { create(:project, project_manager: user) }

  before { rack_session_login(user) }

  describe 'index' do
    it 'shows the projects list' do
      visit projects_path
      expect(page).to have_content(project.name)
    end
  end

  describe 'create' do
    it 'creates a project with valid inputs' do
      visit new_project_path
      fill_in I18n.t('projects.fields.name'), with: 'My New Project'
      fill_in I18n.t('projects.fields.description'), with: 'A description of the project'
      click_button I18n.t('helpers.submit.create', model: 'Project')
      expect(page).to have_content('My New Project')
      expect(page).to have_content(I18n.t('projects.created'))
    end

    it 'shows validation error without name' do
      visit new_project_path
      click_button I18n.t('helpers.submit.create', model: 'Project')
      expect(page).to have_content('Project name cannot be blank')
    end

    it 'shows validation error when end_date before start_date' do
      visit new_project_path
      fill_in I18n.t('projects.fields.name'), with: 'Invalid Date Project'
      fill_in 'project[start_date]', with: Date.today.to_s
      fill_in 'project[end_date]',   with: Date.yesterday.to_s
      click_button I18n.t('helpers.submit.create', model: 'Project')
      expect(page).to have_content('must be after start date')
    end
  end

  describe 'show' do
    it 'displays project details' do
      visit project_path(project)
      expect(page).to have_content(project.name)
    end
  end

  describe 'edit' do
    it 'updates a project' do
      visit edit_project_path(project)
      fill_in I18n.t('projects.fields.name'), with: 'Updated Project Name'
      click_button I18n.t('helpers.submit.update', model: 'Project')
      expect(page).to have_content('Updated Project Name')
      expect(page).to have_content(I18n.t('projects.updated'))
    end
  end

  describe 'delete' do
    it 'deletes a project' do
      visit project_path(project)
      click_link I18n.t('actions.delete')
      expect(page).to have_current_path(projects_path)
      expect(page).to have_content(I18n.t('projects.deleted'))
      expect(page).not_to have_content(project.name)
    end
  end
end