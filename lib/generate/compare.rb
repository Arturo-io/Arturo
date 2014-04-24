module Generate
  class Compare
    attr_reader :repo, :base, 
                :head, :auth_token, 
                :client, :deletes,
                :inserts, :pages

    def initialize(opts = {}) 
      @repo       = opts[:repo]
      @base       = opts[:base]
      @head       = opts[:head]
      @client     = opts[:client]
      @pages      = opts[:pages]

      @deletes    = opts[:deletes] || ["<del class='del'>", "</del>"]
      @inserts    = opts[:inserts] || ["<ins class='ins'>", "</ins>"]
    end

    def execute
      content.inject([]) do |memo, item|
        memo << item unless item.empty? 
        memo
      end.join("\n")
    end

    def content
      diff_files.each.map do |file|
        base_file = fetch_file(file, base)
        head_file = fetch_file(file, head)

        base_file.wdiff(head_file, deletes: deletes, 
                                   inserts: inserts)
                                 
      end 
    end

    def diff_files
      client.compare(@repo, @base, @head)
        .files
        .map do |file| 
          file.filename if pages.include?(file.filename)
      end.compact
    end

    private
    def fetch_file(file_path, sha)
      Github::File.fetch(repo, file_path, sha, client)
    rescue Octokit::NotFound
      ""
    end

  end
end 
