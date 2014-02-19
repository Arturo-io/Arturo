class AddCompareUrl < ActiveRecord::Migration
  def change
    add_column :builds, :commit_url, :string
  end
end
