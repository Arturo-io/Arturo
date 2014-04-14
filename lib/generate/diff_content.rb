module Generate
  class DiffContent
    attr_reader :repo, :base, 
                :head, :auth_token, 
                :client

    def initialize(opts = {}) 
      @repo       = opts[:repo]
      @base       = opts[:base]
      @head       = opts[:head]
      @client     = opts[:client]
    end

    def execute
      content.join("\n")
    end

    def content
      diff_files.each.map do |file|
        base_file = fetch_file(file, base)
        head_file = fetch_file(file, head)

        base_file.wdiff(head_file, :deletes => ["<del class='del'>", "</del>"],
                                   :inserts => ["<ins class='ins'>", "</ins>"])
      end 
    end

    def diff_files
      client.compare(@repo, @base, @head)
        .files
        .map { |file| file.filename}
    end

    private
    def fetch_file(file_path, sha)
      Github::File.fetch(repo, file_path, sha, client)
    rescue Octokit::NotFound => e
      ""
    end

  end
end 
