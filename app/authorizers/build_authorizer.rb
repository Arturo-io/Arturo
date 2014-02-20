class BuildAuthorizer < ApplicationAuthorizer
  def readable_by?(user)
    resource.user[:id] == user[:id] ? true : !resource.repo[:private]
  end
end
