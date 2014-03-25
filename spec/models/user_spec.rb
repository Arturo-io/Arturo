require 'spec_helper'

describe User do

  context '#digest' do
    it 'can create a hash of the username' do
      create_user(id: 1234, login: "some_user", uid: "uid")

      user = User.find(1234)
      expect(user.digest).to eq('d64db13b5eae78bc43093ad0b9cb9f35')
    end

    it 'changes the hash when the login changes' do
      create_user(id: 1234, login: "some_user", uid: "uid")

      user   = User.find(1234)
      original_digest = user.digest
      user.uid   = "Test"
      user.login = "some_other_user"
      expect(original_digest).not_to eq(user.digest)
    end
  end

  context '#create_with_omniauth' do
    before do
      @auth = {
        provider: 'github',
        uid:      '12345',
        info: {
          image:     'image url',
          name:      'test user',
          nickname:  'nick_name',
          email:     'user@something.com',
        },
        credentials: {
          token: 'xyz'
        }
      }.with_indifferent_access

    end

    it 'creates a user with a given auth hash' do
      expect(User.create_with_omniauth(@auth)).to_not be_nil
      user = User.where(uid: '12345').first

      expect(user[:provider]).to eq('github')
      expect(user[:uid]).to eq('12345')
      expect(user[:email]).to eq('user@something.com')
      expect(user[:login]).to eq('nick_name')
      expect(user[:name]).to eq('test user')
      expect(user[:auth_token]).to eq('xyz')
      expect(user[:image_url]).to eq('image url')
    end

    it 'returns the newly created user' do
      user = User.create_with_omniauth(@auth)
      expect(user[:login]).to eq('nick_name')
    end

    it 'triggers the UserSignupEmailWorker' do
      expect(UserSignupEmailWorker).to receive(:perform_async)
      User.create_with_omniauth(@auth)
    end
  end

  context '#find_with_omniauth' do
    it 'finds the user with uid' do
      create_user(id: 123, uid: 'omniauth_user')
      user = User.find_with_omniauth(uid: 'omniauth_user')
      expect(user[:id]).to eq(123)
    end
  end

  context '#update_from_omniauth' do
    it 'updates the auth_token if its different' do
      create_user(id: 42, auth_token: 'bad')
      user = User.find(42)
      expect(user[:auth_token]).to eq('bad')

      user.update_from_omniauth({'credentials' => { 'token' => 'good'}})

      user = User.find(42)
      expect(user[:auth_token]).to eq('good')
    end

    it 'doesnt break on empty token' do
      create_user(id: 42, auth_token: 'good')
      user = User.find(42)
      user.update_from_omniauth({})

      user = User.find(42)
      expect(user[:auth_token]).to eq('good')
    end
  end

end
