class Github::Repo
  class << self
    def sync(user_id)
      user   = User.find(user_id)
      client = client(user[:auth_token])
      repos  = fetch_from_github(client, user[:login])
      create_from_array(user_id, repos)
    end

    def fetch_from_github(client, target_name)
      client.repos(target_name)
    end

    def create_from_array(user_id, repos_hash)
      repos_hash.each do |repo_hash| 
        model = ::Repo.find_by_id(repo_hash.attrs[:id]) || ::Repo.new
        update_attributes(user_id, repo_hash, model).save
      end
    end

    private
    def client(auth_token)
      Octokit::Client.new(access_token: auth_token)
    end 

    def update_attributes(user_id, repo_hash, model)
      model.tap do |new_repo|
        new_repo.user_id = user_id
        repo_hash.attrs.each do |key, value|
          next unless new_repo.respond_to? "#{key.to_s}="
          new_repo.send("#{key}=", value)
        end
      end
    end #def

  end #class << self
end #Github
