class CreateBuilds < ActiveRecord::Migration
  def change
    create_table :builds do |t|
      t.belongs_to :repo
      t.string :status
      t.string :branch
      t.string :commit
      t.string :author
      t.datetime :started_at
      t.datetime :ended_at
      t.timestamps
    end
  end
end
