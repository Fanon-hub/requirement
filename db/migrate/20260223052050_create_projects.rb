class CreateProjects < ActiveRecord::Migration[6.1]
  def change
    create_table :projects do |t|
      t.string  :name,               null: false, limit: 100
      t.text    :description
      t.integer :project_manager_id, null: false
      t.date    :start_date
      t.date    :end_date
      t.integer :status,             null: false, default: 0
      t.timestamps null: false
    end
    add_foreign_key :projects, :users, column: :project_manager_id
    add_index :projects, :project_manager_id
  end
end