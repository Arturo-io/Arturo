module Generate
  module Build 
    class Diff < Generic
      attr_reader :build

      def execute
        output = convert(content, :pdf).force_encoding('UTF-8')
        upload(full_name, "#{sha}_diff.pdf", output).url
      end

      def content
         comparer.execute
      end

      def upload(repo_name, file_name, content)
        Generate::S3.save("#{repo_name}/#{file_name}", content)
      end
      
      private
      def comparer
        options = {
          repo:   full_name,
          base:   build[:before], 
          head:   build[:after],
          pages:  pages(full_name, build[:after]),
          client: client
        }
        Generate::Compare.new(options)
      end

      def default_options
        {}.with_indifferent_access
      end

    end
  end
end
