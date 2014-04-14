class UpdateBuildsTable < ActiveRecord::Migration
  def change
    add_column :builds, :before, :string
    add_column :builds, :after, :string
    remove_column :builds, :compare_url
  end
end
