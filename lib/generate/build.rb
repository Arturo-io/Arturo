class Generate::Build 
  attr_reader :repo, :full_name, 
              :auth_token, :formats,
              :client

  def initialize(repo_id, formats = [:pdf, :epub, :mobi])
    @repo       = Repo.joins(:user).find(repo_id)
    @full_name  = repo[:full_name]
    @auth_token = repo.user[:auth_token]
    @formats    = formats
    @client     = github_client(auth_token)
  end

  def execute
    full_content = content(full_name)
    formats.map do |format|
      output = convert(full_content.force_encoding('UTF-8'), format).force_encoding('UTF-8')
      upload(full_name, "#{sha}.#{format.to_s}", output).url
    end
  end

  def sha
    @sha ||= latest_sha(full_name)
  end

  def latest_sha(repo_name)
    client.commits(repo_name).first.sha
  end

  def upload(repo_name, file_name, content)
    Generate::S3.save("#{repo_name}/#{file_name}", content)
  end

  def convert(content, format_to) 
    Generate::Convert.run(content, format_to)
  end

  def content(full_name)
    Generate::Manifest.new(full_name, client).book_content
  end

  def github_client(auth_token)
    Octokit::Client.new(access_token: auth_token)
  end
end
