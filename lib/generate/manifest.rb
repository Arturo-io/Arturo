class Generate::Manifest
  attr_reader :client, :repo

  def initialize(repo, client = default_client)
    @repo   = repo 
    @client = client
  end

  def config
    @config ||= YAML.load(read_config).with_indifferent_access
  end

  def book_content
    config[:pages].inject("") do |memo, page|
      memo << read_remote_file(page) << "\n"
    end
  end

  def read_remote_file(path)
    Github::File.fetch(repo, path, client)
  end

  private
  def read_config
    read_remote_file("manifest.yml")
  end

  def default_client
    Octokit::Client.new
  end
end
