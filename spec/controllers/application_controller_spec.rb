require 'spec_helper'

describe ApplicationController do
  context '#current_user' do
    it 'returns nil when a user_id is not in session' do
      expect(controller.current_user).to eq(nil)
    end

    it 'finds and returns the user' do
      create_user(id: 42)
      session[:user_id] = 42

      expect(controller.current_user).not_to eq(nil)
    end
  end
end
