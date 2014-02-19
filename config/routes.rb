Arturo::Application.routes.draw do
  root to: 'homepage#index'

  get '/auth/github/callback', to: 'omniauth_github#callback'

  get '/dashboard',  to: 'dashboard#index'
  get '/builds',     to: 'build#index'
  get '/builds/:id', to: 'build#show', as: :build

  post '/hooks/github', to: 'hook#github'

  scope '/user', as: :user do
    get '/logout',          to: 'user#logout'
    get '/login/callback',  to: 'omniauth_github#callback'
  end

  scope '/repositories', as: :repositories do
    get    '/',           to: 'repository#index'
    get    '/sync',       to: 'repository#sync'
    put    '/:id/follow', to: 'repository#follow',   as: :follow
    delete '/:id/follow', to: 'repository#unfollow', as: :unfollow 
  end


  if(Rails.env.development?) 
    require 'sidekiq/web'
    mount Sidekiq::Web, at: '/sidekiq'
  end

end
