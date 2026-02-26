class CreateTasks < ActiveRecord::Migration[6.1]
  def change
    create_table :tasks do |t|
      t.string  :title,       null: false, limit: 200
      t.text    :description
      t.integer :project_id,  null: false
      t.integer :assignee_id
      t.integer :creator_id
      t.date    :due_date
      t.integer :status,      default: 0
      t.integer :priority,    default: 1
      t.timestamps null: false
    end
    add_foreign_key :tasks, :projects
    add_foreign_key :tasks, :users, column: :assignee_id
    add_foreign_key :tasks, :users, column: :creator_id
    add_index :tasks, :project_id
    add_index :tasks, :assignee_id
    add_index :tasks, :creator_id
  end
end