class AddRoleToProjectMembers < ActiveRecord::Migration[6.1]
  def change
    unless column_exists?(:project_members, :role)
      add_column :project_members, :role, :string
    end 
  end
end
