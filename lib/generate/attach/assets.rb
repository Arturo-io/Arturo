module Generate
  module Attach
    class Assets
      attr_reader :converter, :format, :file_keys, :options, :fd

      def initialize(converter, format, fd, options)
        @converter = converter
        @format    = format
        @fd        = fd
        @options   = options
        @file_keys = [:css, 
                      :epub_cover_image, 
                      :template,
                      :include_in_header,
                      :include_before_body,
                      :include_after_body]


      end

      def execute
        attach_other_files
        attach_repo_assets
        attach_generic_files
        attach_default_files
      end

      private
      def attach_fonts
        Dir["#{Rails.root}/lib/generate/assets/fonts/**/*.ttf"].each do |font|
          converter.add_other_file(font)
        end
      end

      def attach_styles
        attach_css("custom.css")
        attach_css("theme.css")
      end

      def attach_css(asset)
        asset_path    = Rails.root.join("lib", "generate","assets", asset).to_s
        options[:css] = [options[:css]].flatten.compact
        options[:css].unshift(asset)
        converter.add_other_file(asset_path)
      end

      def attach_default_files
        if format == :pdf  
          attach_fonts
          attach_pdf_styles
        end
        attach_styles
      end

      def attach_other_files
        file_keys.each { |key| add(key) }
      end

      def attach_repo_assets
        fd.download.each do |path, dl_path|
          option_key = find_path_key(path)
          options[option_key] = File.basename(dl_path)
          converter.add_other_file(dl_path) 
        end
      end

      def attach_generic_files(key = :files)
        return unless options[key]
        options[key].each do |item|
          fd.add_file(item)
        end

        options.delete(key)
      end


      def attach_pdf_styles
        attach_css("pdf.css")
      end

      def add(key)
        return unless options[key]
        options[key].respond_to?(:each) ? add_multiple(key) : add_single(key)
      end

      def add_multiple(key)
        options[key] = options[key].map do |item|
          fd.add_file(item)
          File.basename(item)
        end
      end

      def add_single(key)
        fd.add_file(options[key])
      end

      def find_path_key(opts = options, path)
        opts.key(path) || find_nested_key(opts, path)
      end

      def find_nested_key(opts = options, path)
        found = opts.find do |key, value|
          value.include?(path) if value.respond_to? :include?
        end

        found && found.first
      end

    end
  end
end
