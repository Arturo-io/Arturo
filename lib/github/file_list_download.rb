class Github::FileListDownload
  attr_reader :files, :client, :sha, :repo, :downloaded_paths

  def initialize(opts = {})
    raise FilesRequired unless opts[:files]
    raise RepoRequired  unless opts[:repo]

    @files  = opts[:files]
    @client = opts[:client] || Octokit::Client.new
    @sha    = opts[:sha]
    @repo   = opts[:repo]
  end

  def add_file(path)
    files << path
  end

  def download
    @downloaded_paths = files.map { |path| download_to_temp(path) }
  end

  def delete
    FileUtils.rm tmp_files
  end

  private
  def download_to_temp(path)
    file = File.new(tmp_file(path), "w+")
    file.write fetch_content(path)
    file.path
  ensure
    file.close
  end

  def tmp_file(path)
    extension = File.extname(path)
    base_name = File.basename(path, extension)
    "#{Dir::Tmpname.tmpdir}/#{base_name}#{extension}"
  end

  def fetch_content(path)
    Github::File.fetch(repo, path, sha, client)
  end
end

class FilesRequired < StandardError; end
class RepoRequired  < StandardError; end
