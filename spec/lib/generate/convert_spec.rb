require 'spec_helper'

describe Generate::Convert do
  let(:subject) { Generate::Convert }

  before do
    @fd = double("Github::FileListDownload").as_null_object
  end

  it 'can convert one format to another' do
    double = double()
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
    double = double()
    double.stub(:convert)
    double.should_receive(:some=).with(true)
    double.should_receive(:option=).with(false)

    Docverter::Conversion.should_receive(:new).and_return(double)
    subject.new("#raw markdown", :html, 
                            some: true, 
                            option: false, 
                            file_list_download: @fd).run
  end

  context 'other files' do
    def run_fake_converter(double, options)
      Docverter::Conversion
        .should_receive(:new)
        .and_return(double)

      options[:file_list_download] =  @fd
      subject.new("#raw markdown", :html, options).run
    end

    before do
      @converter = double("Docverter::Conversion").as_null_object
    end

    it 'should assign the other file to the converter' do
      @converter.should_receive(:template=).with('template.html')
      run_fake_converter(@converter, template: "some/template.html")
    end

    it 'should assign the multiple files to the converter' do
      @converter.should_receive(:template=).with(["template.html", "other.html"])
      run_fake_converter(@converter, template: ["one/template.html", "two/other.html"])
    end

    it 'adds the file via :add_other_file' do
      @fd.stub(:download).and_return(['/tmp/xyz/template.html'])
      @converter.should_receive(:add_other_file) do |path|
        expect(path).to eq('/tmp/xyz/template.html')
      end

      run_fake_converter(@converter, template: "assets/template.html")
    end

    it 'can add generic files form :files' do
      @converter.should_not_receive(:files=)
      @fd.stub(:download).and_return(['/tmp/xyz/template.html'])
      @converter.should_receive(:add_other_file).with("/tmp/xyz/template.html")

      run_fake_converter(@converter, files: ["assets/template.html"])
    end

  end

end
