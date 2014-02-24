require 'spec_helper'

describe Generate::Convert do
  it 'can convert one format to another' do
    double = double()
    double.stub(:convert).and_return("<h1>raw markdown</h1>")

    Docverter::Conversion.should_receive(:new) do |from, to, content|
      expect(from).to    eq("markdown")
      expect(to).to      eq("html")
      expect(content).to eq("#raw markdown")
      double 
    end
    converted = Generate::Convert.run("#raw markdown", :html)
    expect(converted).to match(/raw markdown/)
  end

  it 'should assign options to the convert' do
    double = double()
    double.stub(:convert)
    double.should_receive(:some=).with(true)
    double.should_receive(:option=).with(false)

    Docverter::Conversion.should_receive(:new).and_return(double)
    Generate::Convert.run("#raw markdown", :html, some: true, option: false)
  end

end
