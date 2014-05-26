class AddDescr < ActiveRecord::Migration
  def change
    add_column :plans, :description, :string
    add_column :plans, :price, :string
    
    Plan.destroy_all
    free   = Plan.create(name: :open_source,  repos: 0, priority: false, description: "Free Plan", price: 0)
    _solo  = Plan.create(name: :solo, repos: 1, priority: false, description: "Solo Plan($4.99)", price: "499")
    _multi = Plan.create(name: :multi_pass, repos: 10, priority: true, description: "Multi Pass Plan($19.99)", price: "1999")

    User.all.each do |user|
      user.update(plan: free)
    end

  end
end
