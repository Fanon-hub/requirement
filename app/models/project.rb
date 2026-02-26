class Project < ApplicationRecord
  enum status: { pending: 0, in_progress: 1, completed: 2 }

  belongs_to :project_manager, class_name: 'User', foreign_key: "project_manager_id"  
  has_many   :project_members, dependent: :destroy
  has_many  :users, through: :project_members
  has_many   :members, through: :project_members, source: :user
  has_many   :tasks, dependent: :destroy
  # has_one   :project_manager, class_name: 'User', foreign_key: 'project_manager_id'

  validates :name,               presence: true, length: { maximum: 100 }
  validates :description,        length: { maximum: 1000 }
  validates :status,             presence: true
  validates :project_manager_id, presence: true
  validate  :end_date_after_start_date

  scope :active,      -> { where(status: [:pending, :in_progress, :completed]) }
  scope :by_status,   ->(s) { where(status: s) }
  scope :recent,      -> { order(created_at: :desc) }
  scope :by_name,     -> { order(:name) }

  def self.ransackable_attributes(auth_object = nil)
    %w[
      name
      description
      status
      start_date
      end_date
      project_manager_id
      created_at
      updated_at
    ]
  end

  # search by project manager name, project members, etc.
  def self.ransackable_associations(auth_object = nil)
    %w[project_manager]
  end

  def task_completion_rate
    return 0 if tasks.count.zero?
    (tasks.done.count.to_f / tasks.count * 100).round
  end

  def overdue?
    end_date.present? && end_date < Date.today && !completed?
  end

  private

  def end_date_after_start_date
    return unless start_date.present? && end_date.present?
    errors.add(:end_date, :after_start_date) if end_date < start_date
  end
end