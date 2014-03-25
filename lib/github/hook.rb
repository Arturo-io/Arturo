class Github::Hook 
  extend Github::Common

  def self.hook_url
    'https://arturo.io/hooks/github'
  end

  def self.create_hook(repo_id)
    repo   = find_repo(repo_id)
    client = client(repo.user[:auth_token])
    client.create_hook(repo[:full_name], 'web', config, options) 
  rescue Octokit::UnprocessableEntity => e
    nil
  end

  def self.remove_hook(repo_id)
    repo   = find_repo(repo_id)
    client = client(repo.user[:auth_token])
    client.remove_hook(repo[:full_name], repo[:hook_id]) 
  rescue Octokit::UnprocessableEntity => e
    nil
  end

  private
  def self.find_repo(repo_id)
    Repo.joins(:user).find(repo_id)
  end

  def self.options
    {
      events: ['push'],
      active: true
    }
  end

  def self.config
    { 
      url: self.hook_url, 
      content_type: 'json'
    }
  end
end
