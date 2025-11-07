Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  # Custom devise paths for API auth
  devise_for :users, defaults: { format: :json }, path: '', path_names: {
    sign_in: 'auth/login',
    sign_out: 'auth/logout'
  }, controllers: {
    sessions: 'auth/sessions',
    registrations: 'auth/registrations'
  }

  devise_scope :user do
    post 'auth/register', to: 'auth/registrations#create'
  end

  get '/auth/me', to: 'auth/me#show'
  get '/healthz', to: proc { [200, { 'Content-Type' => 'application/json' }, [{ status: 'ok' }.to_json]] }

  # Dashboard & Teams
  namespace :dashboard do
    get 'stats', to: 'dashboard#stats'
    get 'activity', to: 'dashboard#activity'
  end
  get '/teams', to: 'teams#index'
  get '/my-shifts', to: 'my_shifts#index'

  resources :employees do
    member do
      get :availability
      put :availability, action: :update_availability
    end
  end

  resources :shifts do
    member do
      post :assignments, action: :create_assignment
      delete 'assignments/:employee_id', action: :destroy_assignment
    end
  end

  resources :swap_requests, path: 'swap-requests', only: %i[index create show] do
    member do
      post :accept
      post :reject
      post :cancel
    end
  end
end
