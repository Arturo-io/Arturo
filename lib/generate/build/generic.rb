module Generate
  module Build 
    class Generic
      attr_reader :repo, :full_name, :auth_token, :formats,
        :client, :build, :options

      def initialize(build_id, formats = [:pdf, :epub, :mobi], options = {})
        @build      = ::Build.find(build_id)
        @repo       = Repo.joins(:user).find(@build[:repo_id])
        @full_name  = repo[:full_name]
        @auth_token = repo.user[:auth_token]
        @formats    = formats
        @client     = github_client(auth_token)
        @options    = options.merge(default_options)
      end

      def execute
        full_content = content(full_name, sha)
        formats.map do |format|
          output = convert(full_content.force_encoding('UTF-8'), format).force_encoding('UTF-8')
          upload(full_name, "#{sha}.#{format.to_s}", output, format).url
        end
      end

      def sha
        @sha ||= build[:commit]
      end

      def upload(repo_name, file_name, content, format)
        @build.update_status("uploading #{format.to_s}")
        Generate::S3.save("#{repo_name}/#{file_name}", content)
      end

      def convert(content, format) 
        @build.update_status("building #{format.to_s}")
        opts = { file_list_download: file_list_download}
          .merge(parsed_options).with_indifferent_access

        Generate::Convert.new(content, format, opts).run
      end

      def content(full_name, sha)
        tree = sort_paths(tree(full_name, sha))
        tree.inject("") do |memo, path|
          memo << Github::File.fetch(full_name, path, sha, client) << "\n"
        end
      end


      def tree(full_name, sha)
        tree = Github::Tree.fetch(client, full_name, sha).tree
        tree
         .select { |i| i["type"] == "blob" }
         .map    { |i| i["path"]}
         .select { |i| allowed_extensions.include?(File.extname(i)) }
      end

      def github_client(auth_token)
        Octokit::Client.new(access_token: auth_token)
      end

      private
      def file_list_download
        Github::FileListDownload.new(files: [], client: client, sha: sha, repo: full_name)
      end

      def allowed_extensions
        [".txt", ".text", ".md", ".markdown"]
      end

      def sort_paths(paths)
        paths.sort
      end

      def parsed_options
        options
      end

      def default_options
        { :table_of_contents => true,
          "self-contained"   => true
        }
      end
    end
  end
end
