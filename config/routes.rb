Arturo::Application.routes.draw do
  root to: 'homepage#index'

  get '/user/login/callback',  to: 'omniauth_github#callback'
  get '/auth/github/callback', to: 'omniauth_github#callback'

  get '/dashboard', to: 'dashboard#show'
end
