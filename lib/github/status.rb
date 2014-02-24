class Github::Status
  def self.create(client, repo, sha, state, options)
    client.create_status(repo, sha, state, options)
  end
end
