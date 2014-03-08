module BuildHelper
  def link_to_build(build)
    link_to "#{build.repo.name} [#{limit_string(build.commit, 4)}]", 
      url_for(controller: 'build', action: 'show', 
              id: build[:id], only_path: true)
  end

  def link_to_commit(build)
    link_to limit_string(build.commit, 8), 
            build.commit_url, 
            target: '_blank'
  end

  def branch_name(branch)
    limit_string(branch, 10)
  end

  def message(message)
    limit_string(message, 49)
  end

  def status_has_spinner?(status)
    parsed_status = status.to_s.downcase
    ['building', 'queued', 'uploading'].any? do |spinner_status|
      parsed_status.include?(spinner_status)
    end
  end

  def icon(status)
    if status_has_spinner?(status)
      fa_icon("spinner spin") 
    elsif status == "failure" || status == "canceled"
      fa_icon("times-circle") 
    elsif status == "success"
      fa_icon("check-circle") 
    else
      ""
    end
  end

  def build_status(status)
    output = icon(status)
    output << " #{status}"
  end

  def limit_string(string, max)
    return "" unless string
    return string if string.length <= max
    string[0..max]  << "..."
  end

  def link_to_author(author, url, avatar)
    image = (avatar && image_tag(avatar, width: "24", class: "author-avatar")) || ""
    link_to("#{image} #{author}".html_safe, url, target: "_blank")
  end

end
