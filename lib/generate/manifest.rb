class Generate::Manifest
  attr_reader :client, :repo, :sha

  def initialize(repo, sha = nil, client = default_client)
    @repo   = repo 
    @client = client
    @sha    = sha
  end

  def config
    @config ||= YAML.load(read_config).with_indifferent_access
  end

  def pages
    config[:pages]
  end

  def book_content
    pages.inject("") do |memo, page|
      memo << read_remote_file(page) << "\n"
    end
  end

  def read_remote_file(path)
    Github::File.fetch(repo, path, sha, client)
  end

  def has_manifest?
    return true if read_config 
  rescue
    false
  end

  private
  def read_config
    read_remote_file("manifest.yml")
  end

  def default_client
    Octokit::Client.new
  end
end
