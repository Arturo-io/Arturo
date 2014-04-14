class CreateRenameDiffs < ActiveRecord::Migration
  def change
    rename_table :diffs, :build_diffs
  end
end
