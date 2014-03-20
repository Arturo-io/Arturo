class RepoOrg < ActiveRecord::Migration
  def change
    add_column :repos, :org, :string
  end
end
