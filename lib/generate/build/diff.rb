module Generate
  module Build 
    class Diff < Generic
      attr_reader :build

      def execute
        output = convert(content, :pdf).force_encoding('UTF-8')
        upload(full_name, "#{sha}_diff.pdf", output).url
      end

      def content
        "Diff View!".force_encoding('UTF-8')
      end

      def upload(repo_name, file_name, content)
        Generate::S3.save("#{repo_name}/#{file_name}", content)
      end

    end
  end
end
