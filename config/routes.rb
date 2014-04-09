Arturo::Application.routes.draw do
  root to: 'homepage#index'

  get '/auth/github/callback', to: 'omniauth_github#callback'

  get '/documentation',    to: 'documentation#index'
  get '/builds',       to: 'build#index'
  get '/builds/:id',   to: 'build#show', as: :build
  get '/badge/:repo_id', to: 'badge#show', as: :badge

  post '/hooks/github', to: 'hook#github'

  scope '/user', as: :user do
    get '/logout',          to: 'user#logout'
    get '/login/callback',  to: 'omniauth_github#callback'
  end

  scope '/repositories', as: :repositories do
    get    '/',           to: 'repository#index'
    get    '/org/:org',   to: 'repository#index',    as: :org
    get    '/sync',       to: 'repository#sync',     as: :sync
    get    '/:id',        to: 'repository#show',     as: :show
    put    '/:id/follow', to: 'repository#follow',   as: :follow
    delete '/:id/follow', to: 'repository#unfollow', as: :unfollow 
    get    '/:id/build',  to: 'repository#build',    as: :build
  end

  get '/plan', to: 'plan#show'

  if(Rails.env.development?) 
    require 'sidekiq/web'
    mount Sidekiq::Web, at: '/sidekiq'
  end

end
