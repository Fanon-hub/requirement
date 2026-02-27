require 'rails_helper'

RSpec.describe 'Login', type: :system do
  before { driven_by(:rack_test) }

  let!(:user) { create(:user, email: 'test@example.com', password: 'password123') }

  describe 'valid login' do
    it 'signs in with correct credentials and redirects to dashboard' do
      visit login_path
      fill_in 'Email Address', with: 'test@example.com'
      fill_in 'Password',      with: 'password123'
      click_button 'Sign In'
      expect(page).to have_current_path(dashboard_path)
      expect(page).to have_selector(".alert.alert-notice", text: /signed in successfully/i)
    end
  end

  describe 'invalid login' do
    it 'shows error with wrong password' do
      visit login_path
      fill_in 'Email Address', with: 'test@example.com'
      fill_in 'Password',      with: 'wrongpassword'
      click_button 'Sign In'
      expect(page).to have_content(/Invalid .*password/i)
      expect(page).to have_current_path(new_user_session_path)
    end

    it 'shows error with unknown email' do
      visit login_path
      fill_in 'Email Address', with: 'unknown@example.com'
      fill_in 'Password',      with: 'password123'
      click_button 'Sign In'
      expect(page).to have_content(/Invalid .*password/i)
    end
  end

  describe 'guest login' do
    it 'logs in as guest user' do
      visit login_path
      click_button I18n.t('navigation.guest_login')
      expect(page).to have_current_path(dashboard_path)
      expect(page).to have_content("Logged in as Guest")
    end
  end

  describe 'admin guest login' do
    it 'logs in as admin guest and redirects to admin panel' do
      visit login_path
      click_button I18n.t('navigation.admin_guest_login')
      expect(page).to have_current_path(admin_root_path)
      expect(page).to have_content("Dashboard")
    end
  end

  describe 'logout' do
    it 'logs out and redirects to root' do
      log_in_as(user)

      # Logout is a button_to, not a link
      click_button I18n.t('navigation.logout'), match: :first

      expect(page).to have_current_path(root_path)
    end
  end

  describe 'authenticated redirect' do
    it 'redirects logged-in users away from login page' do
      rack_session_login(user)
      visit login_path
      expect(page).to have_current_path(dashboard_path)
    end
  end
end