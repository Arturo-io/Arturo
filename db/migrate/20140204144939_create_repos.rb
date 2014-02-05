class CreateRepos < ActiveRecord::Migration
  def change
    create_table :repos do |t|
      t.belongs_to :user
      t.string  :name
      t.string  :full_name
      t.boolean :private
      t.string  :description
      t.integer :github_id
      t.integer :github_user_id
      t.boolean :fork
      t.string  :default_branch
      t.string  :homepage
      t.datetime :pushed_at
      t.timestamps
    end
  end
end
