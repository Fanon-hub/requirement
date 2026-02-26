class TaskComment < ApplicationRecord
  belongs_to :task
  belongs_to :user

  validates :comment_text, presence: true, length: { maximum: 1000 }

  scope :recent, -> { order(created_at: :desc) }
end