class CreatePlansData < ActiveRecord::Migration
  def change
    free   = Plan.create(name: :free,  repos: 0, priority: false)
    _solo  = Plan.create(name: :solo,  repos: 1, priority: false)
    _multi = Plan.create(name: :multi, repos: 10, priority: true)

    User.all.each do |user|
      user.update(plan: free)
    end
  end
end
