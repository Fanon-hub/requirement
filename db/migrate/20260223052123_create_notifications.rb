class CreateNotifications < ActiveRecord::Migration[6.1]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.string  :notification_type
      t.text    :message
      t.boolean :is_read, default: false
      t.timestamps null: false
    end
  end
end