module Generate
  class DiffContent
    attr_reader :repo, :base, :head, :auth_token

    def initialize(opts = {}) 
      @auth_token = opts[:auth_token]
      @repo       = opts[:repo]
      @base       = opts[:base]
      @head       = opts[:head]
    end

    def execute
      content.join("\n")
    end

    def content
      diff_files.each.map do |file|
        base_file = fetch_file(file, base)
        head_file = fetch_file(file, head)

        base_file.wdiff(head_file, :deletes => ["<del>", "</del>"],
                                   :inserts => ["<ins>", "</ins>"])
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

    def client
      Octokit::Client.new(access_token: auth_token)
    end

  end
end 
