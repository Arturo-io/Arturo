require 'spec_helper'

describe Plan do
  context '#user' do
    it 'can have many users' do
      first = Plan.first
      user  = create_user(plan: first)
      expect(first.users).to eq([user])
    end
  end
end
