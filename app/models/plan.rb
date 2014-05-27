class Plan < ActiveRecord::Base
  include Authority::Abilities
  has_many :users

  def human_name
    name.titleize 
  end
end
