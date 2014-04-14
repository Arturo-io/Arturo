class AddCompareUrlToBuilds < ActiveRecord::Migration
  def change
    add_column :builds, :compare_url, :string
  end
end
