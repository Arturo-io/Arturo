require 'base64'

class Github::File 
  def self.fetch(repo, path, ref = nil, client = default_client)
    options = { path: path,
                ref:  ref || "master" }
    content = client.contents(repo, options).content
    Base64.decode64(content)
  end

  private
  def default_client
    Octokit::Client.new
  end
end

