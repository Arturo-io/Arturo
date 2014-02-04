Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, 
           Rails.application.config.github_key,
           Rails.application.config.github_secret,
           scope: 'user, repo'
end
