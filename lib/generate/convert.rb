class Generate::Convert
  attr_reader :options, :fd, :content, :file_keys, :output_format

  def initialize(content, output_format, opts = {})
    @options       = opts.dup
    @fd            = options.delete(:file_list_download)
    @options       = options
    @output_format = output_format
    @content       = content.dup
  end

  def run
    converter = Docverter::Conversion.new("markdown", output_format.to_s, content) 
    Generate::Attach::Assets.new(converter, output_format, fd, options).execute
    Generate::Attach::Images.new(converter, fd, content).execute!
    assign_options(converter)
    converter.convert
  end

  private

  def assign_options(converter)
    options.each { |k, v| converter.send("#{k}=", v) }
  end

end
