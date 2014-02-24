class Generate::Convert
  def self.run(content, format_to, options = {})
    converter = Docverter::Conversion.new("markdown", format_to.to_s, content) 
    options.each { |option, value| converter.send("#{option}=", value) }
    converter.convert
  end
end
