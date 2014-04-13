require 'spec_helper'

describe Generate::DiffContent do
  let(:subject) { Generate::DiffContent }
  before do  
    @content =  Generate::DiffContent.new(repo: "testrepo", 
                                          base: "base", 
                                          head: "head")

    setup_compare
    setup_fetch
  end

  def setup_compare
    allow(@content).to receive_message_chain(:client, :compare) do
      files = 2.times.map { |i| OpenStruct.new(filename: "some_file_#{i}") }
      OpenStruct.new(files: files)
    end
  end

  def setup_fetch
    allow(Github::File).to receive(:fetch)
      .with("testrepo", "some_file_0", "base", anything)
      .and_return("This is the file some_file_0 on base")

    allow(Github::File).to receive(:fetch)
      .with("testrepo", "some_file_0", "head", anything)
      .and_return("This is the file some_file_0 on head")

    allow(Github::File).to receive(:fetch)
      .with("testrepo", "some_file_1", "base", anything)
      .and_return("This is the file some_file_1 on base")

    allow(Github::File).to receive(:fetch)
      .with("testrepo", "some_file_1", "head", anything)
      .and_return("This is the file some_file_1 on head")
  end

  it 'can get a list of diff_files' do
    files = @content.diff_files
    expect(files).to eq(['some_file_0', 'some_file_1'])
  end

  it 'can get a diff  of a file' do
   expected = ["This is the file some_file_0 on <del>base</del> <ins>head</ins>", 
               "This is the file some_file_1 on <del>base</del> <ins>head</ins>"] 
   expect(@content.content).to eq(expected)
  end

  it 'can recover from a 404 file' do
    expect(Github::File).to receive(:fetch)
      .with("testrepo", "some_file_1", "base", anything) do 
      raise Octokit::NotFound
    end

    expected = ["This is the file some_file_0 on <del>base</del> <ins>head</ins>", 
                "<ins>This is the file some_file_1 on head</ins>"]
    expect(@content.content).to eq(expected)
  end

  it 'returns concatd content' do
    expected = "This is the file some_file_0 on <del>base</del> <ins>head</ins>
This is the file some_file_1 on <del>base</del> <ins>head</ins>"

    expect(@content.execute).to eq(expected)
  end
end
