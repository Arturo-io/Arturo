class RepoBadge
  attr_reader :build

  def initialize(build)
    @build = build
  end

  def url
    "#{base_url}#{param_string}.#{ext}"
  end

  private
  def ext
    'png'
  end

  def param_string
    ['build', build_date, color].join("-")
  end

  def build_date
    build.ended_at.strftime("%Y/%m/%d")
  end 

  def color
    'brightgreen'
  end

  def base_url
    'http://arturo-badges.herokuapp.com/badge/'
  end

end
