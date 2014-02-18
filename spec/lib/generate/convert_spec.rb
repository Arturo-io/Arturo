require 'spec_helper'

describe Generate::Convert do
  it 'can convert one format to another' do
    Docverter::Conversion.should_receive(:run) do |from, to, content|
      expect(from).to    eq("markdown")
      expect(to).to      eq("html")
      expect(content).to eq("#raw markdown")
      "<h1>raw markdown</h1>"
    end
    converted = Generate::Convert.run("#raw markdown", :html)
    expect(converted).to match(/raw markdown/)
  end
end
