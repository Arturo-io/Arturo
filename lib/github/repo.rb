class Github::Repo
  extend Github::Common

  def self.sync(user_id)
    user   = User.find(user_id)
    client = client(user[:auth_token])
    repos  = fetch_from_github(client)
    create_from_array(user_id, repos)
  end

  def self.fetch_repo(client, target_name)
    client.repo(target_name)
  end

  def self.commit(client, target_name, sha)
    client.commit(target_name, sha)
  end

  def self.last_commit(client, target_name)
    Octokit.auto_paginate = false
    client.commits(target_name).first.tap do |commit|
      Octokit.auto_paginate = true 
    end
  end

  def self.fetch_from_github(client)
    user_orgs  = Github::Org.fetch_login_list(client)
    user_repos = client.repos
    orgs_repos = user_orgs.map { |org| client.repos(org) }
    (user_repos + orgs_repos).flatten.compact
  end

  def self.create_from_array(user_id, repos_hash)
    repos_hash.each do |repo_hash| 
      model = ::Repo.find_by_id(repo_hash.attrs[:id]) || ::Repo.new
      update_attributes(user_id, repo_hash, model).save
    end
  end

  private
  def self.update_attributes(user_id, repo_hash, model)
    model.tap do |new_repo|
      new_repo.user_id  = user_id
      new_repo.html_url = repo_hash.rels  && repo_hash.rels[:html].href
      new_repo.org      = repo_hash.owner && repo_hash.owner.login.downcase
      repo_hash.attrs.each do |key, value|
        next unless new_repo.respond_to? "#{key.to_s}="
        new_repo.send("#{key}=", value)
      end
    end
  end #def

end #Github
