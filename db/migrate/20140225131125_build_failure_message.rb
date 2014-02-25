class BuildFailureMessage < ActiveRecord::Migration
  def up
    add_column :builds, :error, :text
  end

  def down
    remove_column :builds, :error
  end
end
