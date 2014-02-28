module RepositoryHelper
  def repo_badge(repo_id, markdown)
    image = badge_url(repo_id: repo_id)
    render('repo_badge', image: image,
                         markdown: @badge_markdown)
  end

  def button(text, location, other_classes = [])
    classes = %w(action button tiny radius) << other_classes 
    link_to text.html_safe, location, class: classes.join(" ")
  end
end
