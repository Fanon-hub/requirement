module SessionHelper
  def log_in_as(user)
    visit login_path
    fill_in 'Email Address', with: user.email
    fill_in 'Password',      with: 'password123'
    click_button 'Sign In'
  end

  def rack_session_login(user)
    page.set_rack_session(user_id: user.id)
  end
end