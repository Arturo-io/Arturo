class ApplicationAuthorizer < Authority::Authorizer
  def self.default(adjective, user)
    user ? true : false
  end

  def readable_by?(user)
    owner?(user)
  end

  private
  def owner?(user)
    resource[:user_id] == (user && user[:id])
  end

end
