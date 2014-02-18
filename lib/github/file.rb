require 'base64'

class Github::File 
  def self.fetch(repo, path, client = default_client)
    content = client.contents(repo, path: path).content
    Base64.decode64(content)
  end

  private
  def default_client
    Octokit::Client.new
  end
end

