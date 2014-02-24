class Generate::Build 
  attr_reader :repo, :full_name, :auth_token, :formats,
              :client, :build, :options

  def initialize(build_id, formats = [:pdf, :epub, :mobi], options = {})
    @build      = ::Build.find(build_id)
    @repo       = Repo.joins(:user).find(@build[:repo_id])
    @full_name  = repo[:full_name]
    @auth_token = repo.user[:auth_token]
    @formats    = formats
    @client     = github_client(auth_token)
    @options    = options.merge(default_options)
  end

  def execute
    full_content = content(full_name, sha)
    formats.map do |format|
      output = convert(full_content.force_encoding('UTF-8'), format).force_encoding('UTF-8')
      upload(full_name, "#{sha}.#{format.to_s}", output, format).url
    end
  end

  def sha
    @sha ||= build[:commit]
  end

  def upload(repo_name, file_name, content, format)
    @build.update_status("uploading #{format.to_s}")
    Generate::S3.save("#{repo_name}/#{file_name}", content)
  end

  def convert(content, format) 
    @build.update_status("building #{format.to_s}")
    Generate::Convert.run(content, format, parsed_options)
  end

  def config(full_name, sha)
    cached_manifests(full_name, sha).config
  end

  def content(full_name, sha)
    cached_manifests(full_name, sha).book_content
  end

  def github_client(auth_token)
    Octokit::Client.new(access_token: auth_token)
  end

  private
  def parsed_options
    options.merge(config(full_name, sha))
     .with_indifferent_access
     .tap do |opts|
        opts.delete(:pages)
    end
  end

  def cached_manifests(full_name, sha)
    @manifests      ||= {}
    @manifests[sha] ||= Generate::Manifest.new(full_name, client, sha)
  end

  def default_options
    { table_of_contents: true,}
  end
end
