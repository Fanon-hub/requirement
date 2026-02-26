ActiveAdmin.register Project do
  config.filters = false 
  menu priority: 2
  permit_params :name, :description, :status, :start_date, :end_date, :project_manager_id
end 