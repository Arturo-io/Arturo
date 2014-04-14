module Generate
  module Build 
    class Diff < Generic
      attr_reader :build

      def execute
        output = convert(content, :pdf).force_encoding('UTF-8')
        upload(full_name, "#{sha}_diff.pdf", output).url
      end

      def content
        Generate::DiffContent
          .new(repo: full_name, base: base, head: sha)
          .execute
      end

      def upload(repo_name, file_name, content)
        Generate::S3.save("#{repo_name}/#{file_name}", content)
      end

      def base
        return 'HEAD~1' if last_commit == sha  
        'master'
      end

      private
      def last_commit
        Github::Repo.last_commit(client, full_name)[:sha]  
      end
    end
  end
end
