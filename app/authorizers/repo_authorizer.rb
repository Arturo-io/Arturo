class RepoAuthorizer < ApplicationAuthorizer
  def updatable_by?(user)
    owner?(user)
  end

  def readable_by?(user)
    resource.user[:id] == user[:id] ? true : !resource[:private]
  end
end
