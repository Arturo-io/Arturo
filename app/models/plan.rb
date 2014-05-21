class Plan < ActiveRecord::Base
  include Authority::Abilities
  has_many :users

end
