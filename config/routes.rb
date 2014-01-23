Arturo::Application.routes.draw do
  root to: 'application#index'
  get '/user',        to: 'user#show'
  get '/user/login',  to: 'user#login'
  get '/user/logout', to: 'user#logout'
  get '/user/login/callback',  to: 'omniauth_github#callback'
  get '/auth/github/callback', to: 'omniauth_github#callback'
end
