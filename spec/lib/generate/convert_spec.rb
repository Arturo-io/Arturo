require 'spec_helper'

describe Generate::Convert do

  before do
    @fd = double("Github::FileListDownload").as_null_object
    @fd.stub(:download).and_return({})
  end

  it 'can convert one format to another' do
    double = double().as_null_object
    double.should_receive(:convert)

    Docverter::Conversion.should_receive(:new) do |from, to, content|
      expect(from).to    eq("markdown")
      expect(to).to      eq("html")
      expect(content).to eq("#raw markdown")
      double 
    end

    subject.new("#raw markdown", :html, file_list_download: @fd).run
  end

  it 'should assign options to the convert' do
    double = double().as_null_object
    double.stub(:convert)
    double.should_receive(:some=).with(true)
    double.should_receive(:option=).with(false)

    Docverter::Conversion.should_receive(:new).and_return(double)
    subject.new("#raw markdown", :html, 
                            some: true, 
                            option: false, 
                            file_list_download: @fd).run
  end



end
