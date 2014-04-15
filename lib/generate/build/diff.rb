module Generate
  module Build 
    class Diff < Generic
      attr_reader :build

      def execute
        output = convert(content, :pdf).force_encoding('UTF-8')
        upload(full_name, "#{sha}_diff.pdf", output).url
      end

      def content
        Generate::Compare.new(repo: full_name, 
                              base: build[:before], 
                              head: build[:after],
                              client: client)
          .execute
      end

      def upload(repo_name, file_name, content)
        Generate::S3.save("#{repo_name}/#{file_name}", content)
      end
      
      private
      def default_options
        {}.with_indifferent_access
      end

    end
  end
end
