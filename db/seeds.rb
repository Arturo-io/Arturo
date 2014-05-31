# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
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
                     stripe_description: "Solo Plan ($4.99/month)",
                     price: 499)

_multi = Plan.create(name: :multi_pass,
                     repos: 10,
                     priority: true,
                     description: "For Serial Writers",
                     stripe_description: "Multi Pass Plan ($19.99)/month",
                     price: 1999)

