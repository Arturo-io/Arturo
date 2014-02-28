class Generate::Book 
  def initialize(build_id, formats)
    @build_id = build_id
    @formats  = formats
  end

  def execute
    builder.new(@build_id, @formats).execute
  end

  def builder
    if has_manifest? 
      Generate::Build::Manifest
    else
      Generate::Build::Generic
    end
  end

  def has_manifest?
    @has_manifest ||= lookup_manifest
  end

  def lookup_manifest
    build  = Build.find(@build_id)
    sha    = build[:commit]
    client = client(build.user[:auth_token])
    Generate::Manifest
      .new(build.repo[:full_name], sha, client)
      .has_manifest?
  end

  private
  def client(auth_token)
    Octokit::Client.new(access_token: auth_token)
  end
end
