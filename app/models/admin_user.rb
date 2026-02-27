class AdminUser < ApplicationRecord
  devise :database_authenticatable, 
         :recoverable, :rememberable, :validatable

  def self.admin_guest
    find_or_create_by!(email: 'admin.guest@taskflow.demo') do |admin|
      admin.password              = 'guestadmin2025'   
      admin.password_confirmation = admin.password
    end
  end
end