class Generate::Convert
  def self.run(content, format_to)
    Docverter::Conversion.run("markdown", format_to.to_s, content) 
  end
end
