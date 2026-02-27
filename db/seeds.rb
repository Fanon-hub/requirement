# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

puts "🌱 Starting seed..."

# --- Users ---
puts "Creating users..."

admin = User.find_or_create_by!(email: 'admin@taskflow.com') do |u|
  u.name     = 'Admin User'
  u.password = 'password123'
  u.admin    = true
end

users = [
  { name: 'Alice Johnson', email: 'alice@taskflow.com' },
  { name: 'Bob Smith',     email: 'bob@taskflow.com'   },
  { name: 'Carol White',   email: 'carol@taskflow.com' },
  { name: 'David Lee',     email: 'david@taskflow.com' },
  { name: 'Eva Martinez',  email: 'eva@taskflow.com'   },
].map do |attrs|
  User.find_or_create_by!(email: attrs[:email]) do |u|
    u.name     = attrs[:name]
    u.password = 'password123'
    u.admin    = false
  end
end

User.guest_user
User.admin_guest_user
puts "  ✓ #{User.count} users created"

# --- Projects ---
puts "Creating projects..."

projects_data = [
  {
    name: 'Website Redesign',
    description: 'Redesign the company website to improve user experience and modern aesthetics.',
    status: :in_progress,
    start_date: 1.month.ago,
    end_date: 1.month.from_now
  },
  {
    name: 'Mobile App v2',
    description: 'Second major version of the mobile application with new features and improved performance.',
    status: :in_progress,
    start_date: 2.weeks.ago,
    end_date: 2.months.from_now
  },
  {
    name: 'Data Migration',
    description: 'Migrate all legacy database records to the new cloud infrastructure safely.',
    status: :pending,
    start_date: Date.today,
    end_date: 3.months.from_now
  },
  {
    name: 'API Integration',
    description: 'Integrate third-party payment and analytics APIs into the platform.',
    status: :completed,
    start_date: 1.month.ago,
    end_date: 3.weeks.from_now
  },
  {
    name: 'Security Audit Q1',
    description: 'Quarterly security review covering infrastructure, code, and access controls.',
    status: :completed,
    start_date: 2.months.ago,
    end_date: 1.week.ago
  },
]

projects = projects_data.map do |attrs|
  Project.find_or_create_by!(name: attrs[:name]) do |p|
    p.description     = attrs[:description]
    p.status          = attrs[:status]
    p.start_date      = attrs[:start_date]
    p.end_date        = attrs[:end_date]
    p.project_manager = admin
  end
end
puts "  ✓ #{Project.count} projects created"

# --- Project Members ---
puts "Creating project members..."

projects.each_with_index do |project, i|
  ProjectMember.find_or_create_by!(project: project, user: admin) do |pm|
    pm.role      = :manager
    pm.joined_at = Date.today
  end
  assigned_users = [users[i % 5], users[(i + 1) % 5], users[(i + 2) % 5]]
  assigned_users.each do |user|
    ProjectMember.find_or_create_by!(project: project, user: user) do |pm|
      pm.role      = [:viewer, :contributor, :manager, :admin].sample
      pm.joined_at = Date.today - rand(1..30).days
    end
  end
end
puts "  ✓ #{ProjectMember.count} project memberships created"

# --- Tasks ---
puts "Creating tasks..."

task_templates = [
  { title: 'Define project scope and objectives',       description: 'Work with stakeholders to define clear scope, goals, and success criteria.', status: :done,        priority: :high   },
  { title: 'Design system architecture',                description: 'Create technical architecture diagrams and documentation.',                   status: :done,        priority: :high   },
  { title: 'Set up development environment',            description: 'Configure local dev environments, Docker containers, and CI/CD pipelines.',   status: :done,        priority: :medium },
  { title: 'Implement user authentication',             description: 'Build login, registration, and session management functionality.',            status: :in_progress, priority: :high   },
  { title: 'Build dashboard UI',                        description: 'Create the main dashboard with stats, charts, and navigation.',               status: :in_progress, priority: :medium },
  { title: 'Write API documentation',                   description: 'Document all API endpoints with examples using OpenAPI/Swagger.',             status: :pending,     priority: :low    },
  { title: 'Conduct user testing sessions',             description: 'Recruit 5 users and run structured usability testing sessions.',              status: :pending,     priority: :medium },
  { title: 'Performance optimization',                  description: 'Profile and optimize slow queries, reduce bundle size, improve load times.',  status: :pending,     priority: :high   },
  { title: 'Deploy to staging environment',             description: 'Set up staging server and automate deployment from main branch.',             status: :pending,     priority: :medium },
  { title: 'Final QA and launch preparation',           description: 'Full regression test, smoke tests, and go-live checklist.',                  status: :pending,     priority: :high   },
]

projects.each do |project|
  task_templates.first(5).each_with_index do |tmpl, i|
    # Get project members to assign tasks to
    project_members = project.users.to_a
    assignee = project_members.sample || admin
    
    task = Task.find_or_create_by!(title: "#{project.name} — #{tmpl[:title]}") do |t|
      t.description = tmpl[:description]
      t.status      = tmpl[:status]
      t.priority    = tmpl[:priority]
      t.due_date    = Date.today + ((i + 1) * 7).days
      t.project     = project
      t.creator     = admin
      t.assignee    = assignee
    end

    # Add comments to each task
    3.times do |j|
      TaskComment.find_or_create_by!(task: task, user: project_members.sample || admin, comment_text: "Update #{j+1}: Work on '#{task.title}' is progressing as planned. No blockers at this time.") do |c|
      end
    end
  end
end
puts "  ✓ #{Task.count} tasks created"
puts "  ✓ #{TaskComment.count} comments created"

# --- Notifications ---
puts "Creating notifications..."

users.each do |user|
  5.times do |i|
    types = ['task_assigned', 'comment_added', 'deadline_approaching', 'project_update', 'mention']
    Notification.find_or_create_by!(user: user, message: "Notification #{i+1}: #{['You have been assigned a new task.', 'A comment was added to your task.', 'A task deadline is approaching.', 'Your project status was updated.', 'You were mentioned in a comment.'][i]}") do |n|
      n.notification_type = types[i]
      n.is_read           = i > 2
    end
  end
end
puts "  ✓ #{Notification.count} notifications created"

puts ""
puts "✅ Seed complete!"
puts "   Users:         #{User.count}"
puts "   Projects:      #{Project.count}"
puts "   Members:       #{ProjectMember.count}"
puts "   Tasks:         #{Task.count}"
puts "   Comments:      #{TaskComment.count}"
puts "   Notifications: #{Notification.count}"
puts ""
puts "🔑 Login credentials:"
puts "   Admin:       admin@taskflow.com / password123"
puts "   User:        alice@taskflow.com / password123"
puts "   Guest:       Click 'Try as Guest' on the login page"
puts "   Admin Guest: Click 'Admin Demo' on the login page"
AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password') if Rails.env.development?
