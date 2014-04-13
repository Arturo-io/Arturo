require 'spec_helper'

describe Generate::BookDiff do 
  let(:subject) {  Generate::BookDiff }
  
  context'#initialize' do
    it 'sets the build id' do
      diff = subject.new(1)
      expect(diff.build_id).to eq(1) 
    end
  end
end
