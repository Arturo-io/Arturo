require 'spec_helper'

describe RepoBadge do
  let(:subject) { RepoBadge }

  context '#initialize' do
    it 'with hash param' do
      subject.new(repo_id: 1, branch: :master)
    end

    it 'requires the param' do
      expect { subject.new }.to raise_error(ArgumentError)
    end

    it 'finds the last successful build' do
      Build
       .should_receive(:last_successful_build)
       .with(1, :master)
      subject.new(repo_id: 1, branch: :master)
    end

    it 'sets the extension to the passed in extension' do
      badge = subject.new(repo_id: 1, branch: :master, ext: "xyz")
      expect(badge.ext).to eq("xyz") 
    end

    it 'sets the extension to a default value' do
      badge = subject.new(repo_id: 1, branch: :master)
      expect(badge.ext).to eq("png")
    end

    it 'sets the branch to a default value' do
      badge = subject.new(repo_id: 1)
      expect(badge.branch).to eq("master")
    end
  end

  context '#url' do
    before do
      params = { repo_id: 1, branch: :master}
      @badge = RepoBadge.new(params)
    end

    it 'returns a full url' do 
      @badge.stub(:base_url).and_return("http://example.com/")
      @badge.stub(:param_string).and_return("stuff")
      @badge.stub(:ext).and_return("jpg")

      expect(@badge.url).to eq("http://example.com/stuff.jpg")
    end
  end

  context 'private' do
    before do
      params = { repo_id: 1, branch: :master}
      @badge = RepoBadge.new(params)
    end

    context '#build_date' do
     it 'returns the date/time of last build' do
        time  = Time.parse("2014-01-01 15:34:23")
        build = OpenStruct.new(ended_at: time)

        @badge.stub(:build).and_return build
        expect(@badge.send(:build_date)).to eq("2014/01/01")
      end
    end

    context '#param_string' do
      it 'returns a cat\'d string' do
        @badge.stub(:build_date).and_return('2000/01/01')
        @badge.stub(:color).and_return('red')

        param = @badge.send(:param_string) 
        expect(param).to eq('build-2000/01/01-red')
      end
    end

    context 'defaults' do
      it '#default_branch' do
        expect(@badge.send(:default_branch)).to eq('master')
      end

      it '#default_ext' do
        expect(@badge.send(:default_ext)).to eq('png')
      end

      it '#prefix' do
        expect(@badge.send(:prefix)).to eq("build")
      end

      it '#base_url' do
        expect(@badge.send(:base_url)).to eq("http://arturo-badges.herokuapp.com/badge/")
      end

      it '#color' do
        expect(@badge.send(:color)).to eq("brightgreen")
      end

    end

  end
end
