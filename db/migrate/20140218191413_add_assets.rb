class AddAssets < ActiveRecord::Migration
  def change
    create_table :assets do |t|
      t.belongs_to :build
      t.string :url
      t.timestamps
    end
  end
end
