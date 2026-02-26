class CreateProjectMembers < ActiveRecord::Migration[6.1]
  def change
    create_table :project_members do |t|
      t.references :project, null: false, foreign_key: true
      t.references :user,    null: false, foreign_key: true
      t.integer    :role,    null: false, default: 0
      t.date       :joined_at, null: false
      t.timestamps null: false
    end
    add_index :project_members, [:project_id, :user_id], unique: true
  end
end