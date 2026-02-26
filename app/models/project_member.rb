class ProjectMember < ApplicationRecord
  enum role: {
    viewer:   0,
    editor:   1,
    manager:  2,
    admin:    3
  }, _prefix: true

  belongs_to :project
  belongs_to :user

  validates :role,      presence: true
  validates :joined_at, presence: true
  validates :user_id,   uniqueness: { scope: :project_id, message: :already_member }

  before_validation :set_joined_at

  private

  def set_joined_at
    self.joined_at ||= Date.today
  end
end