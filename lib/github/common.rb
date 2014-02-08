module Github::Common
  def client(auth_token)
    Octokit::Client.new(access_token: auth_token)
  end 
end
