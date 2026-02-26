# app/admin/dashboard.rb  – full corrected version
ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
    columns do
      column do
        panel "Recent Projects" do
          if Project.any?
            ul do
              Project.order(created_at: :desc).limit(5).each do |project|
                li do
                  a project.name, href: "/admin/projects/#{project.id}"
                end
              end
            end
          else
            para "No projects yet."
          end
        end

        panel "Recent Tasks" do
          if Task.any?
            ul do
              Task.order(created_at: :desc).limit(5).each do |task|
                li do
                  a task.title, href: "/admin/tasks/#{task.id}"
                end
              end
            end
          else
            para "No tasks yet."
          end
        end
      end

      column do
        panel "Recent Users" do
          if User.any?
            ul do
              User.order(created_at: :desc).limit(5).each do |user|
                li do
                  display_name = user.name.presence || user.email
                  a display_name, href: "/admin/users/#{user.id}"
                end
              end
            end
          else
            para "No users yet."
          end
        end

        panel "Quick Stats" do
          attributes_table_for :stats do
            row "Total Projects" do Project.count end
            row "Total Tasks"    do Task.count    end
            row "Total Users"    do User.count    end
          end
        end
      end
    end
  end
end