class Github::Org
  extend Github::Common

  def self.fetch_from_github(client)
    client.orgs
  end

  def self.fetch_login_list(client)
    fetch_from_github(client).map { |org| org["login"] }
  end
end
