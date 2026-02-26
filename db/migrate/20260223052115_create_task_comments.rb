class CreateTaskComments < ActiveRecord::Migration[6.1]
  def change
    create_table :task_comments do |t|
      t.text    :comment_text, null: false
      t.references :task, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.timestamps null: false
    end
  end
end