module Generate
  module Build 
    class Manifest < Generic

      def content(full_name, sha)
        cached_manifests(full_name, sha).book_content
      end

      def config(full_name, sha)
        cached_manifests(full_name, sha).config.tap do |config|
          Generate::ManifestValidator.new(config).validate!
        end
      end

      private
      def parsed_options
        options.merge(config(full_name, sha))
         .with_indifferent_access
         .tap do |opts|
          opts.delete(:pages)
        end
      end

      def cached_manifests(full_name, sha)
        @manifests      ||= {}
        @manifests[sha] ||= Generate::Manifest.new(full_name, sha, client)
      end

    end
  end
end
