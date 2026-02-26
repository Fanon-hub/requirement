class Task < ApplicationRecord
  enum status:   { pending: 0, in_progress: 1, done: 2 }
  enum priority: { low: 0, medium: 1, high: 2 }

  belongs_to :project
  belongs_to :assignee, class_name: 'User', foreign_key: :assignee_id, optional: true
  belongs_to :creator,  class_name: 'User', foreign_key: :creator_id
  has_many   :task_comments, dependent: :destroy

  validates :title,       presence: true, length: { maximum: 200 }
  validates :description, length: { maximum: 2000 }
  validates :status,      presence: true
  validates :priority,    presence: true

  scope :by_due_date,   -> { order(due_date: :asc) }
  scope :high_priority, -> { where(priority: :high) }
  scope :incomplete,    -> { where.not(status: :done) }
  scope :overdue,       -> { where('due_date < ?', Date.today).incomplete }
  scope :recent,        -> { order(created_at: :desc) }
  scope :by_status,     ->(s) { where(status: s) }
  scope :by_priority,   ->(p) { where(priority: p) }
  scope :assigned_to,   ->(user) { where(assignee_id: user.id) }

  def self.ransackable_attributes(auth_object = nil)
    %w[
      title
      description
      status
      priority
      due_date
      assignee_id
      creator_id
      project_id
      created_at
      updated_at
    ]
  end

  # Search ransack on associations
  def self.ransackable_associations(auth_object = nil)
    %w[assignee creator project]
  end

  def overdue?
    due_date.present? && due_date < Date.today && !done?
  end

  def days_until_due
    return nil unless due_date.present?
    (due_date - Date.today).to_i
  end

  def status_class
    case status
    when 'done'        then 'text-green-600'
    when 'in_progress' then 'text-blue-600'
    when 'pending'     then 'text-yellow-600'
    else 'text-gray-600'
    end
  end

  def priority_class
    case priority
    when 'high'   then 'text-red-600 font-medium'
    when 'medium' then 'text-orange-600'
    when 'low'    then 'text-green-600'
    else 'text-gray-500'
    end
  end
end