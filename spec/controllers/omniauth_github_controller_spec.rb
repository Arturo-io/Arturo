require 'spec_helper'

describe OmniauthGithubController do
  context 'callback' do
    it 'updates the auth token with a new one' do
      hash = {
        uid: 'ortuna',
        credentials: {
          token: 'good'
        }
      }.with_indifferent_access
      request.env["omniauth.auth"] = hash

      create_user(uid: 'ortuna', auth_token: 'bad')
      get :callback

      user = User.find_by_uid('ortuna')
      expect(user[:auth_token]).to eq('good')
    end
  end
end
