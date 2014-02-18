class Github::Repo
  extend Github::Common

  def self.sync(user_id)
    user   = User.find(user_id)
    client = client(user[:auth_token])
    repos  = fetch_from_github(client, user[:login])
    create_from_array(user_id, repos)
  end

  def self.fetch_repo(client, target_name)
    client.repo(target_name)
  end

  def self.last_commit(client, target_name)
    client.commits(target_name).first
  end

  def self.fetch_from_github(client, target_name)
    client.repos(target_name)
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
      new_repo.user_id = user_id
      repo_hash.attrs.each do |key, value|
        next unless new_repo.respond_to? "#{key.to_s}="
        new_repo.send("#{key}=", value)
      end
    end
  end #def

end #Github
