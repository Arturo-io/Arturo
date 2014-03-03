class RepoBadge
  attr_reader :repo_id, :branch, :build, :ext

  def initialize(params)
    @repo_id = params[:repo_id]
    @branch  = params[:branch] || default_branch
    @ext     = params[:ext]    || default_ext
    @build   = Build.last_successful_build(repo_id, branch)
  end

  def url
    "#{base_url}#{param_string}.#{ext}"
  end

  private
  def default_branch
    'master'
  end

  def default_ext
    'png'
  end

  def param_string
    ['build', build_date, color].join("-")
  end

  def build_date
    build.ended_at.strftime("%Y/%m/%d")
  end 

  def prefix
    'build'
  end

  def color
    'brightgreen'
  end

  def base_url
    'http://arturo-badges.herokuapp.com/badge/'
  end

end
