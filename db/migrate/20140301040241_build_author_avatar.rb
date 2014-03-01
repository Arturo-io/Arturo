class BuildAuthorAvatar < ActiveRecord::Migration
  def up 
    add_column :builds, :author_avatar, :string
    add_column :builds, :author_url, :string
  end
  
  def down
    remove_column :builds, :author_avatar
    remove_column :builds, :author_url
  end

end
