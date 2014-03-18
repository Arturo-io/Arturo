require 'spec_helper'

describe Generate::Attach::Images do
  let(:subject) { Generate::Attach::Images }
  before do
    @fd        = double("FileDownloader").as_null_object
    @converter = double("Converter").as_null_object
    @downloads = { 
      "image/cover.jpg"  => "/tmp/TMPcover.jpg",
      "image/figure.jpg" => "/tmp/TMPfigure.jpg",
    }
    
    @markdown = <<-markdown
      ![cover](image/cover.jpg)
      ![figure](image/figure.jpg)
    markdown
  end

  def execute_subject(markdown)
    subject.new(@converter, @fd, markdown).execute! 
  end

  it 'adds all the images to the file downloader' do
    expect(@fd)
      .to receive(:add_file)
      .with("image/cover.jpg")

    execute_subject("![alt text](image/cover.jpg)")
  end

  it 'adds a unique name to the file downloader' do
    expect(@fd).to receive(:download).and_return(@downloads)

    execute_subject(@markdown)

    expect(@markdown).to include "![cover](TMPcover.jpg)"
    expect(@markdown).to include "![figure](TMPfigure.jpg)"
  end

  it 'adds to other files for the converter' do
    expect(@fd).to receive(:download).and_return(@downloads)

    expect(@converter).to receive(:add_other_file).with("/tmp/TMPcover.jpg")
    expect(@converter).to receive(:add_other_file).with("/tmp/TMPfigure.jpg")

    execute_subject(@markdown)
  end

end
