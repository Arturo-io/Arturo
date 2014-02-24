class AddJobIdBuilds < ActiveRecord::Migration
  def up 
    add_column :builds, :job_id, :string
  end
  
  def down
    remove_column :builds, :job_id
  end
end
