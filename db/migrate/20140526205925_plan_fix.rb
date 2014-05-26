class PlanFix < ActiveRecord::Migration
  def change
    remove_column :plans, :price
    add_column :plans, :price, :integer
    add_column :plans, :stripe_description, :string

    Plan.destroy_all
    free   = Plan.create(name: :open_source,
                         repos: 0,
                         priority: false,
                         description: "For Open Source Projects",
                         stripe_description: "Open Source Plan(free)",
                         price: 0)

    _solo  = Plan.create(name: :solo,
                         repos: 1,
                         priority: false,
                         description: "For Solo Writers",
                         stripe_description: "Solo Plan($4.99)",
                         price: 499)

    _multi = Plan.create(name: :multi_pass,
                         repos: 10,
                         priority: true,
                         description: "For Serial Writers",
                         stripe_description: "Multi Pass Plan($19.99)",
                         price: 1999)

    User.all.each do |user|
      user.update(plan: free)
    end


  end
end
