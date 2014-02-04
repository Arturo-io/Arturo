Arturo::Application.routes.draw do
  root to: 'application#index'

  get '/user/login/callback',  to: 'omniauth_github#callback'
  get '/auth/github/callback', to: 'omniauth_github#callback'

  get '/dashboard', to: 'dashboard#show'
end
