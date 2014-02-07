class ApplicationAuthorizer < Authority::Authorizer
  def self.default(adjective, user)
    return true if user
    false 
  end

  def readable_by?(user)
    owner?(user)
  end

  private
  def owner?(user)
    resource[:user_id] == user[:id]
  end

end
