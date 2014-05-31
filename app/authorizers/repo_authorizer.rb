class RepoAuthorizer < ApplicationAuthorizer
  def creatable_by?(user)
    if(resource[:private])
      !repo_limit_reached?(user) && owner?(user)
    else
      owner?(user)
    end
  end

  def updatable_by?(user)
    owner?(user)
  end

  def readable_by?(user)
    resource.user[:id] == user[:id] ? true : !resource[:private]
  end

  private
  def repo_limit_reached?(user)
    user.repo_limit_reached?
  end

end
