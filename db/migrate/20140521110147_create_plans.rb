class CreatePlans < ActiveRecord::Migration
  def change
    remove_column :users, :plan
    add_column    :users, :plan_id, :integer

    create_table :plans do |t|
      t.string  :name
      t.integer :repos
      t.boolean :priority
      t.timestamps
    end
  end
end
