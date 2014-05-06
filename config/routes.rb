Arturo::Application.routes.draw do
  root to: 'homepage#index'

  get '/auth/github/callback', to: 'omniauth_github#callback'

  get '/documentation',  to: 'documentation#index'
  get '/builds',         to: 'builds#index'
  get '/builds/:id',     to: 'builds#show', as: :build
  get '/badge/:repo_id', to: 'badge#show', as: :badge

  post '/hooks/github',  to: 'hooks#github'

  scope '/user', as: :user do
    get '/logout',          to: 'user#logout'
    get '/login/callback',  to: 'omniauth_github#callback'
  end

  scope '/repositories',  as: :repositories do
    get    '/',           to: 'repositories#index'
    get    '/org/:org',   to: 'repositories#index',    as: :org
    get    '/sync',       to: 'repositories#sync',     as: :sync
    get    '/:id',        to: 'repositories#show',     as: :show
    put    '/:id/follow', to: 'repositories#follow',   as: :follow
    delete '/:id/follow', to: 'repositories#unfollow', as: :unfollow 
    get    '/:id/build',  to: 'repositories#build',    as: :build
    get    '/:latest',    to: 'repositories#last_build',   as: :latest
  end


  if(Rails.env.development?) 
    require 'sidekiq/web'
    mount Sidekiq::Web, at: '/sidekiq'
  end

end
