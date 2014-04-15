require 'spec_helper'

describe Generate::ManifestOptions do
  let(:subject) { Generate::ManifestOptions }

  it 'can take in a config as an option' do 
    subject.new({option: "value"}) 
  end

  context 'validate options' do
    it 'valid options' do  
      subject.new({author: "ortuna", title: "Hamlet"}).validate! 
    end

    it 'invalid options' do
      expect {
        subject.new({another_option: true, author: "ortuna", title: "Hamlet"}).validate! 
      }.to raise_error(Generate::InvalidOption)
    end
  end
  
end
