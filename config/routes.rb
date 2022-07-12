Rails.application.routes.draw do
  resource :session, only: [:destroy]
  resources :profile, only: [:index]

  resources :maintenance

  resources :workspaces
  resources :contactus
  resources :announcements

  get '/users/last_viewed', to: 'users#last_viewed'
  resources :users

  get '/reset_password', to: 'sessions#reset_password'

  get '/auth/login', to: 'sessions#login'
  post '/auth/route', to: 'sessions#route'
  get '/auth/route', to: 'sessions#redirect'

  get '/auth/logout', to: 'sessions#destroy'

  get '/auth/azureactivedirectory', as: :sign_in

  match '/auth/:provider/callback', to: 'sessions#create', via: [:get, :post]
  
  match '/oauth2/callback', to: 'sessions#create', via: [:get, :post]
  

  match '/authorize', to: 'signed_in#add_auth', via: [:get, :post]
  
  match '/auth/:provider/failure', to: redirect('/'), via: [:get, :post]

  get '/', to: 'reports#index'

  get '/workspaces/:id/reports', to: 'workspaces#reports'

  get '/mps', to: 'sessions#mps'

  get '/mps/callback', to: 'sessions#mps_callback'

  get '/mps/authorize', to: 'sessions#mps_authorize'
  
  get '/ops/check', to: 'operations#check'
  get '/ops/version', to: 'operations#version'

  resources :workspaces do
    resources :users
  end

  post '/reports/token', to: 'reports#token'
  post '/reports/refresh_token', to: 'reports#refresh_token'

  get '/admin', to: 'admin#index'

  get '/admin/people', to: 'admin#people'

  post '/admin/confirm_b2c_status', to: 'admin#confirm_b2c_status'
end
