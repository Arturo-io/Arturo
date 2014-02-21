require 'spec_helper'

describe BadgeController do
  let(:url) { "http://arturo-badges.herokuapp.com/badge/" }

  context '#show' do
    it 'redirects you when visiting' do
      controller.stub(:badge_params).and_return("build-12-brightgreen")
      get :show, repo_id: 1, branch: :master
      assert_redirected_to url << "build-12-brightgreen.png"
    end
  end

  context '#badge_params' do
    it 'finds the better param' do
      create_user(id: 42)
      
      Repo.create(id: 1, user_id: 42, name: 'some_repo', private: false)
      12.times { |n| Build.create(id: n, repo_id: 1) }

      params = controller.send(:badge_params, 1, :master)
      expect(params).to eq('build-11-brightgreen')
    end
  end
end
