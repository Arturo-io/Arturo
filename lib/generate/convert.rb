class Generate::Convert
  attr_reader :options, :fd, :converter

  def initialize(content, output_format, opts = {})
    @options       = opts.dup
    @fd            = options.delete(:file_list_download)
    @options       = options

    @converter     = Docverter::Conversion.new("markdown", output_format.to_s, content) 
  end

  def run
    add_other_files
    download_and_attach
    assign_options
    converter.convert
  end

  private
  def assign_options
    options.each do |option, value| 
      converter.send("#{option}=", value)
    end
  end

  def add_other_files
    add(:css)
    add(:template)
    add(:include_in_header)
    add(:include_before_body)
    add(:include_after_body)
  end

  def download_and_attach
    fd.download.each do |path|
      converter.add_other_file(path) 
    end
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
    options[key] = File.basename(options[key])
  end


end
