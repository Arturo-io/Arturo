class CreateDiff < ActiveRecord::Migration
  def change
    create_table :diffs do |t|
      t.belongs_to :build 
      t.string :url
      t.timestamps
    end
  end
end
