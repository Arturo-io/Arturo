Arturo::Application.routes.draw do
  root to: 'homepage#index'

  get '/user/login/callback',  to: 'omniauth_github#callback'
  get '/auth/github/callback', to: 'omniauth_github#callback'

  get '/user/logout',  to: 'user#logout'

  get '/dashboard', to: 'dashboard#index'

  get '/builds', to: 'build#index'

  get '/repositories',      to: 'repository#index'
  get '/repositories/sync', to: 'repository#sync'

  require 'sidekiq/web'
  mount Sidekiq::Web, at: '/sidekiq'

end
