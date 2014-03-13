class Generate::Convert
  attr_reader :options, :fd, :converter, :file_keys

  def initialize(content, output_format, opts = {})
    @options       = opts.dup
    @fd            = options.delete(:file_list_download)
    @options       = options
    @converter     = Docverter::Conversion.new("markdown", output_format.to_s, content) 
    @file_keys     = [:css, 
                      :epub_cover_image, 
                      :template,
                      :include_in_header,
                      :include_before_body,
                      :include_after_body]

  end

  def run
    attach_other_files
    attach_repo_assets
    attach_generic_files
    attach_default_files

    assign_options
    converter.convert
  end

  private
  def assign_options
    options.each do |option, value| 
      converter.send("#{option}=", value)
    end
  end

  def attach_default_files
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

  def attach_styles
    styles_path = Rails.root.join("lib", "generate","assets","theme.css").to_s
    options[:css] = [options[:css]].compact.flatten
    options[:css].unshift("theme.css")
    converter.add_other_file(styles_path)
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


end
