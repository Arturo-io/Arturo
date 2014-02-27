class RepoAddHtmlUrl < ActiveRecord::Migration
  def up 
    add_column :repos, :html_url, :string
  end
  
  def down
    remove_column :repos, :html_url
  end

end
