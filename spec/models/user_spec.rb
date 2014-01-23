require 'spec_helper'

describe User do

  context '#create_with_omniauth' do
    it 'creates a user with a given auth hash' do
      auth = {
        provider: 'github',
        uid:      '12345',
        info: {
          image:     'image url',
          name:      'test user',
          nickname:  'nick_name',
        },
        credentials: {
          token: 'xyz'
        }
      }.with_indifferent_access
      expect(User.create_with_omniauth(auth)).to_not be_nil
      user = User.where(uid: '12345').first

      expect(user[:provider]).to eq('github')
      expect(user[:uid]).to eq('12345')
      expect(user[:login]).to eq('nick_name')
      expect(user[:name]).to eq('test user')
      expect(user[:auth_token]).to eq('xyz')
      expect(user[:image_url]).to eq('image url')
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
