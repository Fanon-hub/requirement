class Notification < ApplicationRecord
  belongs_to :user

  validates :message, presence: true

  scope :unread,  -> { where(is_read: false) }
  scope :recent,  -> { order(created_at: :desc).limit(20) }

  def self.create_for(user, type, message)
    create!(user: user, notification_type: type, message: message)
  end
end