class User < ApplicationRecord

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  # has_secure_password

  has_many :managed_projects, class_name: 'Project', foreign_key: :project_manager_id, dependent: :nullify
  has_many :project_members,  dependent: :destroy
  has_many :projects,         through: :project_members
  has_many :created_tasks,    class_name: 'Task', foreign_key: :creator_id,  dependent: :nullify
  has_many :assigned_tasks,   class_name: 'Task', foreign_key: :assignee_id, dependent: :nullify
  has_many :task_comments,    dependent: :destroy
  has_many :notifications,    dependent: :destroy

  validates :name,  presence: true, length: { maximum: 50 }
  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }

  before_save { self.email = email.downcase }

  scope :admins,       -> { where(admin: true) }
  scope :regular_users,-> { where(admin: false, guest: false) }
  scope :by_name,      -> { order(:name) }

  def self.ransackable_attributes(auth_object = nil)
    super + %w[
      name
      email
      display_name     # if you have this field
      # Add any other fields you want searchable, e.g.:
      # role
      # created_at
      # admin
    ]
  end
  
  def self.ransackable_associations(auth_object = nil)
    super + %w[
      # e.g. if you search tasks or projects created by user:
      # tasks
      # projects
    ]
  end

  def self.guest_user
    find_or_create_by!(email: 'guest@taskflow.com') do |u|
      u.name     = 'Guest User'
      u.password = SecureRandom.urlsafe_base64
      u.guest    = true
      u.admin    = false
    end
  end

  def self.admin_guest_user
    find_or_create_by!(email: 'admin.guest@taskflow.com') do |u|
      u.name     = 'Admin Guest'
      u.password = SecureRandom.urlsafe_base64
      u.role    = 'guest'
      u.role    = 'admin'
    end
  end

  def admin?
    role == "admin"
  end

  def display_name
    name.presence || email.split('@').first
  end

  def initials
    name.split.map(&:first).join.upcase.first(2)
  end
end