module RepositoryHelper
  def asset_button_link(asset)
    url       = asset.url
    extension = File.extname(url) 
    content_tag(:a, class: 'button secondary radius', href: url) do
      ext_icon(extension) + human_readable_ext(extension)
    end
  end

  def tab_link(user, org) 
    disabled_class = org == @org ? 'disabled' : 'secondary'
    link_to tab_label(user, org), 
            repositories_org_path(org),
            class: "button tiny org #{disabled_class}"
  end

  def repo_badge(repo_id, markdown)
    image = badge_url(repo_id: repo_id)
    render('repo_badge', image: image,
                         markdown: @badge_markdown)
  end

  def button(text, location, other_classes = [])
    classes = %w(action button tiny radius) << other_classes 
    link_to text.html_safe, location, class: classes.join(" ")
  end

  def followed_org_count(user, org)
    Follower
      .with_user(user)
      .where(repos: { org: org })
      .count
  end

  private
  def ext_icon(extension)
    fa_icon(icons[extension])
  end

  def human_readable_ext(extension)
    return extensions[extension] if extensions.include?(extension)
  end

  def icons
   { ".pdf" => 'file-pdf-o',
     ".html" => 'file-code-o',
     ".epub" => 'file-o',
     ".mobi" => 'file-o'}
  end

  def extensions
    { ".pdf" => 'PDF',
      ".html" => 'Read Online',
      ".epub" => 'EPUB',
      ".mobi" => 'MOBI'}
  end

  def tab_label(user, org)
    count = followed_org_count(user, org)
    tag   = content_tag(:span, count, class: "label secondary radius")
    tag   = count == 0 ? '' : tag

    "#{org} #{tag}".html_safe
  end

end
