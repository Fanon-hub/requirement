class AddDeviseColumnsToUsers < ActiveRecord::Migration[6.1]
  def change
    # Main password column for Devise
    add_column :users, :encrypted_password, :string, null: false, default: "" unless column_exists?(:users, :encrypted_password)

    # Recoverable
    add_column :users, :reset_password_token,   :string unless column_exists?(:users, :reset_password_token)
    add_column :users, :reset_password_sent_at, :datetime unless column_exists?(:users, :reset_password_sent_at)

    # Rememberable
    add_column :users, :remember_created_at, :datetime unless column_exists?(:users, :remember_created_at)

    # Trackable
    add_column :users, :sign_in_count,         :integer, default: 0 unless column_exists?(:users, :sign_in_count)
    add_column :users, :current_sign_in_at,    :datetime unless column_exists?(:users, :current_sign_in_at)
    add_column :users, :last_sign_in_at,       :datetime unless column_exists?(:users, :last_sign_in_at)
    add_column :users, :current_sign_in_ip,    :string unless column_exists?(:users, :current_sign_in_ip)
    add_column :users, :last_sign_in_ip,       :string unless column_exists?(:users, :last_sign_in_ip)

    # Confirmable (email confirmation)
    add_column :users, :confirmation_token,   :string unless column_exists?(:users, :confirmation_token)
    add_column :users, :confirmed_at,         :datetime unless column_exists?(:users, :confirmed_at)
    add_column :users, :confirmation_sent_at, :datetime unless column_exists?(:users, :confirmation_sent_at)
    add_column :users, :unconfirmed_email,    :string unless column_exists?(:users, :unconfirmed_email)

    # Indexes (important for performance & uniqueness)
    add_index :users, :email,                unique: true unless index_exists?(:users, :email)
    add_index :users, :reset_password_token, unique: true unless index_exists?(:users, :reset_password_token)
    add_index :users, :confirmation_token,   unique: true unless index_exists?(:users, :confirmation_token)
  end
end