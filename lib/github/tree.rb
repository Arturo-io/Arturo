class Github::Tree
  def self.fetch(client, repo, sha)
    client.tree(repo, sha, recursive: true)
  end
end
