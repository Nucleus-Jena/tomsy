Rails.application.routes.draw do
  devise_for :users
  mount RailsAdmin::Engine => "/admin", :as => "rails_admin"

  root to: "home#show"
  get "home/show"

  namespace :api do
    resources :ambitions, only: [:index, :show, :update, :create, :destroy] do
      collection do
        get :list
      end
      member do
        get :activities
        patch :update_private_status
        patch :update_assignee
        patch :update_contributors
        patch :update_processes
        patch :close
        patch :reopen
        post :comment
      end
    end
    resources :process_definitions, only: [:index]

    resources :processes, only: [:index, :show, :update, :create] do
      collection do
        get :list
      end
      member do
        get :activities
        patch :update_private_status
        patch :update_assignee
        patch :update_contributors
        patch :update_ambitions
        patch :cancel
        post :comment
      end
    end

    resources :tasks, only: [:index, :show, :update] do
      collection do
        get :list
      end
      member do
        get :activities
        patch :update_assignee
        patch :update_contributors
        patch :update_marked
        patch :update_due_date
        patch :complete
        post :comment
        get :data, action: :show_data
        patch :data, action: :update_data
        post :create_document
        patch :update_document
        delete :destroy_document
      end
    end

    resources :users, only: [:index, :show] do
      collection do
        get :list
      end
      member do
        get :info
      end
    end

    resources :notifications, only: [:index] do
      collection do
        patch :mark_all
      end
      member do
        patch :mark
      end
    end

    get "search/fulltext"

    resources :dossiers, only: [:index, :show, :new, :create, :update, :destroy] do
      collection do
        get :list
      end
      member do
        get :show_references
      end
    end

    resources :dossier_definitions, only: [:index]
  end

  get "*path", to: "home#show", constraints: ->(request) do
    !request.xhr? && request.format.html?
  end
end
