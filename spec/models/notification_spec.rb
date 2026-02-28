require 'rails_helper'

RSpec.describe Notification, type: :model do
  describe 'validations and scopes' do
    let(:user) { create(:user) }

    it 'is invalid without a message' do
      expect(build(:notification, message: nil)).not_to be_valid
    end

    it '.unread returns only unread notifications' do
      n1 = create(:notification, user: user, is_read: false)
      n2 = create(:notification, user: user, is_read: true)
      expect(Notification.unread).to include(n1)
      expect(Notification.unread).not_to include(n2)
    end

    it '.recent returns most recent notifications' do
      create(:notification, user: user, created_at: 2.days.ago)
      recent = create(:notification, user: user, created_at: 1.hour.ago)
      expect(Notification.recent.first).to eq(recent)
    end

    it '.create_for creates a notification for a user' do
      expect { Notification.create_for(user, 'info', 'hello') }.to change { Notification.count }.by(1)
    end
  end
end
