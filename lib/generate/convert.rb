class Generate::Convert
  attr_reader :options, :fd, :converter, :file_keys, :output_format

  def initialize(content, output_format, opts = {})
    @options       = opts.dup
    @fd            = options.delete(:file_list_download)
    @options       = options
    @output_format = output_format
    @converter     = Docverter::Conversion.new("markdown", output_format.to_s, content) 
  end

  def run
    Generate::Attach::Assets.new(converter, output_format, fd, options).execute
    assign_options
    converter.convert
  end

  private

  def assign_options
    options.each do |option, value| 
      converter.send("#{option}=", value)
    end
  end

end
