Rails.application.routes.draw do
  apipie
  mount ActionCable.server => '/api/v1/channels'
  mount ResqueWeb::Engine => "/resque"

  namespace :api do
    namespace :v1 do
      # get "/raise" => "matches#test_exception"
      resources :positions,    only: %i(index) do
        collection do
          get :warning_log
        end
      end
      resources :sports,       only: %i(index update)
      resources :matches,      only: %i(index) do
        collection do
          get :groups
          get :player_groups
        end
      end
      namespace :player do
        resources :categories, only: %i(index)
        resources :orders,     only: %i(index) do
          collection do
            get :recent
          end
        end
        resources :balances do
          collection do
            get :weekly
          end
        end
      end
      namespace :users do
        resources :profiles,  only: %i() do
          collection do
            get :show
            patch :update
          end
        end
      end
      resources :categories,   only: %i(index update) do
        collection do
          get :default
          get :with_matches
        end
      end
      resources :orders,       only: %i(index) do
        collection do
          get :history
        end
      end
      resources :teams
      resources :groups

      get    '/admin/index',                     to: 'admins#index'
      post   '/admin/create',                    to: 'admins#create'
      patch  '/admin/update',                    to: 'admins#update'
      delete '/admin/delete',                    to: 'admins#destroy'
      get   '/admin/role_index',                 to: 'admins#role_index'
      get   '/admin/:id/roles',                  to: 'admins#show_roles'
      post  '/admin/add_role',                   to: 'admins#add_role'
      post  '/admin/remove_role',                to: 'admins#remove_role'
      get   '/users/:id/reports',                to: 'users#reports'
      get   '/users/reports/statistics',         to: 'users#statistic_reports'
      get   '/user_settings',                    to: 'users#settings'
      post  '/user_settings/return_all_rebate',  to: 'users#return_all_rebate'
      post  '/user_settings/return_none_rebate', to: 'users#return_none_rebate'
      post  '/users/validation_auto_adjust',     to: 'users#validation_auto_adjust'
      get   '/user_allotters',                   to: 'users#allotters'
      get   '/users/downline_list',              to: 'users#downline_list'
      get   '/users/downline_profile',           to: 'users#downline_profile'
      get   '/users/username_repeat',            to: 'users#username_repeat'
      post  '/users/update_password',            to: 'users#update_password'
      post  '/sign_in',                          to: 'users#sign_in'
      post  '/sign_up',                          to: 'users#sign_up'
      post  '/cache_categories',                 to: 'categories#set_cache'
      patch '/users/settings',                   to: 'users#update_setting'
      patch '/users/allotters',                  to: 'users#update_allotters'
      get   '/commits',                          to: 'statuses#commits'
    end
  end

  namespace :logs do
    resources :errors do
      collection do
        post :archive
      end
    end
  end

  namespace :pushes do
    resources :logs, only: %i(show) do
      collection do
        get "uuid/:uuid" => "logs#uuid"
      end
    end

    resources :matches, only: %i(index show) do
      collection do
        get :filter
        get '/tx/:id' => 'matches#tx'
      end
      member do
        get :offers
      end
      resources :logs, only: %i(show)
    end
    resources :offers
  end

  resources :documents

  root to: 'mocks#index'
  get    '/manager'            => 'mocks#manager'
  get    '/player'             => 'mocks#player'
  get    '/player/parlays'     => 'mocks#parlays'
  delete '/history'            => 'mocks#delete_orders'
  delete '/mocks/delete_all'   => 'mocks#delete_all'
  get    '/results'            => 'mocks#results'
  get    '/results_submit'     => 'mocks#results_submit'
  get    '/cookies/reset'      => 'mocks#cookies_reset'
  get    '/asians'             => 'mocks#asians'
  get    '/asians/recalculate' => 'mocks#recalculate_asians'
  get    '/asians/:id'         => 'mocks#reasian'
  get    '/history'            => 'mocks#history'
  get    '/broadcast'          => 'mocks#broadcast'
  post   '/broadcast'          => 'mocks#send_broadcast'
end
