module BuildHelper
  def link_to_repo(build)
    link_to "#{build.repo.name} ##{build.id}", 
      url_for(controller: 'build', action: 'show', 
              id: build[:id], only_path: true)
  end

  def link_to_commit(build)
    link_to limit_string(build.commit, 8), 
            build.commit_url, 
            target: '_blank'
  end

  def branch_name(branch)
    limit_string(branch, 8)
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

  def build_status(status)
    output = status_has_spinner?(status) ? fa_icon("spinner spin") : ""
    output << " #{status}"
  end

  private
  def limit_string(string, max)
    return "" unless string
    return string if string.length < max
    string[0..max]  << "..."
  end
end
