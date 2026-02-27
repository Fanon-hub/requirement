module SessionHelper
  def log_in_as(user)
    # Prefer named login route if available, otherwise use Devise's path
    visit defined?(login_path) ? login_path : new_user_session_path
    fill_in 'Email Address', with: user.email
    fill_in 'Password',      with: 'password123'
    click_button 'Sign In'
  end

  def rack_session_login(user)
    # Use Warden test helpers when available (fast), otherwise fall back to UI sign-in
    if defined?(login_as)
      login_as(user, scope: :user)
    else
      log_in_as(user)
    end
  end
end