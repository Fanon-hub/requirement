Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'registrations' }

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  root 'pages#top'

  get 'dashboard', to: 'user_dashboard#index', as: :dashboard

  resources :users, only: [:show, :edit, :update]

  resources :projects, controller: 'user_projects' do
    member do
      get    :members
      post   :add_member
      delete :remove_member
    end

    resources :tasks, controller: 'user_tasks' do
      resources :task_comments, only: [:create, :destroy], shallow: true
      member do
        patch :update_status
      end
    end
  end

  resources :notifications, only: [:index] do
    member   { patch :mark_read }
    collection { patch :mark_all_read }
  end

  match '/404', to: 'errors#not_found',     via: :all
  match '/500', to: 'errors#internal_server_error', via: :all

  devise_scope :user do
    post 'users/guest_login',       to: 'users/guest_sessions#guest_login',       as: :users_guest_login
    post 'users/admin_guest_login', to: 'users/guest_sessions#admin_guest_login', as: :users_admin_guest_login
  end
end