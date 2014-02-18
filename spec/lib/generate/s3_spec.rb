require 'spec_helper'

describe Generate::S3 do
  let(:subject) { Generate::S3 }

  it 'can save content to S3' do 
    bucket = double("bucket")
    bucket.stub(:content=)
    bucket.stub(:save)

    bucket.stub_chain(:objects, :build) do |path|
      expect(path).to eq("ortuna/progit-bana/file.xyz")
      bucket
    end

    subject.stub(:bucket).and_return(bucket)
    subject.save("Ortuna/Progit-bana/file.xyz", "some content")  
  end
end
