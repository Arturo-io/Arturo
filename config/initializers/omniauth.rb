Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, 
           Rails.application.config.github_key,
           Rails.application.config.github_secret,
           scope: 'user:email, repo, read:repo_hook, write:repo_hook'
end
