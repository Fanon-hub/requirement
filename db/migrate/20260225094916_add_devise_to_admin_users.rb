# db/migrate/20260225094916_add_devise_to_admin_users.rb
class AddDeviseToAdminUsers < ActiveRecord::Migration[6.1]
  def change
    change_table :admin_users do |t|
      # Database authenticatable
      unless column_exists?(:admin_users, :email)
        t.string :email, null: false, default: ""
      end

      unless column_exists?(:admin_users, :encrypted_password)
        t.string :encrypted_password, null: false, default: ""
      end

      # Recoverable
      unless column_exists?(:admin_users, :reset_password_token)
        t.string :reset_password_token
      end

      unless column_exists?(:admin_users, :reset_password_sent_at)
        t.datetime :reset_password_sent_at
      end

      # Rememberable
      unless column_exists?(:admin_users, :remember_created_at)
        t.datetime :remember_created_at
      end

      # Trackable - uncomment if you want login tracking
      unless column_exists?(:admin_users, :sign_in_count)
        t.integer :sign_in_count, default: 0, null: false
      end
      unless column_exists?(:admin_users, :current_sign_in_at)
        t.datetime :current_sign_in_at
      end
      unless column_exists?(:admin_users, :last_sign_in_at)
        t.datetime :last_sign_in_at
      end
      unless column_exists?(:admin_users, :current_sign_in_ip)
        t.inet :current_sign_in_ip
      end
      unless column_exists?(:admin_users, :last_sign_in_ip)
        t.inet :last_sign_in_ip
      end

      # Confirmable - uncomment if you want email confirmation
      # unless column_exists?(:admin_users, :confirmation_token)
      #   t.string :confirmation_token
      # end
      # unless column_exists?(:admin_users, :confirmed_at)
      #   t.datetime :confirmed_at
      # end
      # unless column_exists?(:admin_users, :confirmation_sent_at)
      #   t.datetime :confirmation_sent_at
      # end
      # unless column_exists?(:admin_users, :unconfirmed_email)
      #   t.string :unconfirmed_email
      # end

      # Lockable - uncomment if you want account locking
      # unless column_exists?(:admin_users, :failed_attempts)
      #   t.integer :failed_attempts, default: 0
      # end
      # unless column_exists?(:admin_users, :unlock_token)
      #   t.string :unlock_token
      # end
      # unless column_exists?(:admin_users, :locked_at)
      #   t.datetime :locked_at
      # end

      # Timestamps (only add if they don't exist and you didn't have them before)
      # unless column_exists?(:admin_users, :created_at)
      #   t.timestamps
      # end
    end

    # Indexes - only add if missing
    unless index_exists?(:admin_users, :email)
      add_index :admin_users, :email, unique: true
    end

    unless index_exists?(:admin_users, :reset_password_token)
      add_index :admin_users, :reset_password_token, unique: true
    end

    # Uncomment if using confirmable or lockable
    # unless index_exists?(:admin_users, :confirmation_token)
    #   add_index :admin_users, :confirmation_token, unique: true
    # end
    # unless index_exists?(:admin_users, :unlock_token)
    #   add_index :admin_users, :unlock_token, unique: true
    # end
  end
end