module Generate
  class InvalidOption < Exception; end

  class ManifestValidator
    attr_reader :config

    def initialize(config)
      @config = config
    end


    def validate!
      config.each do |option, value|
        next if valid?(option)
        raise InvalidOption, "#{option} is an invalid manifest option"
      end
    end

    private
    def valid?(option)
      valid_options.include? option.to_s
    end

    def valid_options
      %w(author title pages formats files css stylesheet table_of_contents 
         epub_cover_image template include_in_header include_before_body include_after_body)
    end
  end
end
