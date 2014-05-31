class Generate::Book 
  class PrivateRepoLimitReached < StandardError; end

  def initialize(build_id, formats)
    @build_id = build_id
    @formats  = formats
  end

  def execute
    check_build_limit if private_repo?
    builder.new(@build_id, formats: @formats).execute
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
    sha    = build[:commit]
    client = client(build.user[:auth_token])
    Generate::Manifest
      .new(build.repo[:full_name], sha, client)
      .has_manifest?
  end

  private
  def private_repo?
    build.repo.private
  end
  
  def check_build_limit
    raise_error unless build.user.within_repo_limit?
  end

  def build
    @build ||= ::Build.find(@build_id)
  end

  def raise_error
    message = <<-eos
You have reached the private repository limit on your account.
Please unfollow some repositories or upgrade your account. 
eos
    raise PrivateRepoLimitReached, message
  end

  def client(auth_token)
    Octokit::Client.new(access_token: auth_token)
  end
end
