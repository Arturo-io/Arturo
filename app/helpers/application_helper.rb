module ApplicationHelper

  def repository_link(following_ids, repository)
    if following_ids.include?(repository.id)
      link_to repository.name, repositories_show_path(repository) 
    else
      repository.name
    end
  end

  def following_link(following_ids, repository)
    is_following = following_ids.include?(repository.id)
    icon         = following_icon(is_following)
    create_link(repository, is_following, icon).html_safe
  end

  private
  def create_link(repo, is_following, icon)
    method = is_following ? :delete : :put 
    path   = is_following ? repositories_follow_path(repo) : repositories_unfollow_path(repo) 
    link_to(icon, path, method: method)
  end

  def following_icon(is_following)
    is_following ? fa_icon('check-square') : fa_icon('minus-square') 
  end

  def render_menu(user)
    partial = user ? 'user_links' : 'anon_links'
    render "shared/#{partial}"
  end

  def limit_string(string, max)
    return "" unless string
    return string if string.length <= max
    string[0..max]  << "..."
  end

end
