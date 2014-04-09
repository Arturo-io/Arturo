require 'spec_helper'

describe Github::FileListDownload do
  let(:subject) { Github::FileListDownload }

  it 'requires :files on init' do
    expect { subject.new }.to raise_error(FilesRequired)
  end

  it 'requires :repo on init' do
    expect { subject.new(files: []) }.to raise_error(RepoRequired)
  end

  it 'can take in a custom client' do
    file_list = subject.new(files: [], repo: 'some_repo', client: OpenStruct.new)
    expect(file_list.client).not_to be_nil 
  end

  it 'can take in a sha' do
    file_list = subject.new(files: [], repo: 'some_repo', sha: 'sha123')
    expect(file_list.sha).to eq('sha123')
  end

  it 'can add to the files' do
    file_list = subject.new(files: [], repo: 'some_repo')
    file_list.add_file 'new_file.css' 

    expect(file_list.files).to eq(['new_file.css'])
  end 
  
  it 'downloads all files given from github' do
    file_list = subject.new(files: ['readme.md'], repo: 'some_repo')
    file_list.stub(:fetch_content)

    local_files = file_list.download
    expect(local_files['readme.md']).to match(/readme.*md$/)
  end

  it 'deletes all the tmp files' do
    paths = {'file1.md' => '/tmp/file1.md', 'file2.md' => '/tmp/file2.md'}
    file_list = subject.new(files: ['readme.md'], repo: 'some_repo')
    file_list.stub(:downloaded_paths).and_return(paths)

    expect(FileUtils).to receive(:rm).with(['/tmp/file1.md', '/tmp/file2.md'])
    file_list.delete
  end

  it 'can query the downloaded paths' do
    file_list = subject.new(files: ['readme.md'], repo: 'some_repo')
    file_list.stub(:fetch_content)

    paths = file_list.download
    expect(paths['readme.md']).not_to be_nil
  end
end

