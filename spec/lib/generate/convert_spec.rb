require 'spec_helper'

describe Generate::Convert do
  let(:subject) { Generate::Convert }

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
    expect(double).to receive(:some=).with(true)
    expect(double).to receive(:option=).with(false)

    expect(Docverter::Conversion).to receive(:new).and_return(double)

    subject.new("#raw markdown", :html, 
                            some: true, 
                            option: false, 
                            file_list_download: @fd).run
  end

  context 'asset assignment' do
    before do 
      Docverter::Conversion.should_receive(:new).and_return(double().as_null_object)
    end

    def run_subject
      subject.new("#raw markdown", :html, file_list_download: @fd).run
    end

    it 'adds assets' do
      allow_any_instance_of(Generate::Attach::Assets).to receive(:execute)
      run_subject
    end

    it 'adds images' do
      allow_any_instance_of(Generate::Attach::Images).to receive(:execute!)
      run_subject
    end
  end



end
