class Generate::Build 
  attr_reader :repo, :full_name, 
              :auth_token, :formats,
              :client, :build

  def initialize(build_id, formats = [:pdf, :epub, :mobi])
    @build      = ::Build.find(build_id)
    @repo       = Repo.joins(:user).find(@build[:repo_id])
    @full_name  = repo[:full_name]
    @auth_token = repo.user[:auth_token]
    @formats    = formats
    @client     = github_client(auth_token)
  end

  def execute
    full_content = content(full_name, sha)
    formats.map do |format|
      output = convert(full_content.force_encoding('UTF-8'), format).force_encoding('UTF-8')
      upload(full_name, "#{sha}.#{format.to_s}", output).url
    end
  end

  def sha
    @sha ||= build[:commit]
  end

  def upload(repo_name, file_name, content)
    Generate::S3.save("#{repo_name}/#{file_name}", content)
  end

  def convert(content, format_to) 
    Generate::Convert.run(content, format_to)
  end

  def content(full_name, sha)
    Generate::Manifest.new(full_name, client, sha).book_content
  end

  def github_client(auth_token)
    Octokit::Client.new(access_token: auth_token)
  end
end
