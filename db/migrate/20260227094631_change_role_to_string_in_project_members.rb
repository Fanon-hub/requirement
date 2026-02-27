class ChangeRoleToStringInProjectMembers < ActiveRecord::Migration[6.1]
  def change
    change_column :project_members, :role, :string
  end
end
