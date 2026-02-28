require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(build(:user)).to be_valid
    end

    it 'is invalid without a name' do
      user = build(:user, name: nil)
      expect(user).not_to be_valid
      expect(user.errors[:name]).to be_present
    end

    it 'is invalid with name over 50 characters' do
      expect(build(:user, name: 'a' * 51)).not_to be_valid
    end

    it 'is invalid without an email' do
      expect(build(:user, email: nil)).not_to be_valid
    end

    it 'is invalid with a duplicate email' do
      create(:user, email: 'test@example.com')
      expect(build(:user, email: 'test@example.com')).not_to be_valid
    end

    it 'is invalid with a malformed email' do
      expect(build(:user, email: 'notanemail')).not_to be_valid
    end

    it 'is invalid without a password' do
      expect(build(:user, password: nil)).not_to be_valid
    end
  end

  describe 'scopes' do
    let!(:admin)  { create(:user, :admin) }
    let!(:member) { create(:user) }

    it '.admins returns only admin users' do
      expect(User.admins).to include(admin)
      expect(User.admins).not_to include(member)
    end

    it '.regular_users excludes admins and guests' do
      expect(User.regular_users).to include(member)
      expect(User.regular_users).not_to include(admin)
    end
  end

  describe '.guest_user' do
    it 'creates a guest user if none exists' do
      User.where(email: 'guest@taskflow.com').delete_all
      expect { User.guest_user }.to change { User.count }.by(1)
    end

    it 'returns the same guest user on repeated calls' do
      guest = User.guest_user
      expect(User.guest_user).to eq(guest)
    end
  end

  describe '#initials' do
    it 'returns first two initials' do
      user = build(:user, name: 'Alice Johnson')
      expect(user.initials).to eq('AJ')
    end
  end
end