require 'rails_helper'

RSpec.describe AdminUser, type: :model do
  describe '.admin_guest' do
    it 'creates a guest admin if none exists' do
      AdminUser.where(email: 'admin.guest@taskflow.demo').delete_all
      expect { AdminUser.admin_guest }.to change { AdminUser.count }.by(1)
    end

    it 'returns the same admin on repeated calls' do
      guest = AdminUser.admin_guest
      expect(AdminUser.admin_guest).to eq(guest)
    end

    it 'has recoverable and validatable Devise modules enabled' do
      admin = AdminUser.admin_guest
      expect(admin.valid_password?('guestadmin2025')).to be true
      expect(admin.email).to eq('admin.guest@taskflow.demo')
    end
  end
end
