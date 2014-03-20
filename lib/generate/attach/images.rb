module Generate
  module Attach
    class Images
      attr_reader :converter, :downloader, :content

      def initialize(converter, fd, content)
        @converter  = converter
        @content    = content
        @downloader = fd
      end

      def execute!
        content.gsub(/\!\[.*\]\((?!http)(.*)\)/i) do |_url|
          downloader.add_file $1
        end
        download_and_replace
        content
      end

      private
      def download_and_replace
        downloader.download.each do |original, tmp|
          base_name = File.basename(tmp)
          converter.add_other_file(tmp)

          content.gsub!(/(\!\[.*\]\()(#{original})(\))/i, "\\1#{base_name}\\3")
        end
      end

    end
  end
end
