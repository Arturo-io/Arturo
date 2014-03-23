module Generate
  class InvalidOption < Exception; end

  class ManifestOptions
    attr_reader :config

    def initialize(config)
      @config = config
    end


    def validate!
      config.each do |option, value|
        raise InvalidOption, "#{option} is an invalid manifest option" unless valid? option
      end
    end

    private
    def valid?(option)
      valid_options.include? option
    end

    def valid_options
      %i(author title pages files css stylesheet table_of_contents 
         epub_cover_image template include_in_header include_before_body include_after_body)
    end
  end
end
