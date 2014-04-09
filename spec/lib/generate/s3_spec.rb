require 'spec_helper'

describe Generate::S3 do
  let(:subject) { Generate::S3 }

  it 'can save content to S3' do 
    bucket = double("bucket")
    allow(bucket).to receive(:content=)
    allow(bucket).to receive(:save)

    allow(bucket).to receive_message_chain(:objects, :build) do |path|
      expect(path).to eq("ortuna/progit-bana/file.xyz")
      bucket
    end

    allow(subject).to receive(:bucket).and_return(bucket)
    subject.save("Ortuna/Progit-bana/file.xyz", "some content")  
  end
end
