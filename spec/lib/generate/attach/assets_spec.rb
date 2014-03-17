require 'spec_helper'

describe Generate::Attach::Assets do
  before do
    @fd = double("Github::FileListDownload").as_null_object
    @fd.stub(:download).and_return({})
  end

  context 'other files' do
    def fake_converter(double = @converter, format = :html, options)
      Docverter::Conversion
        .should_receive(:new)
        .and_return(double)

      options[:file_list_download] =  @fd
      Generate::Convert.new("#raw markdown", format, options)
    end

    before do
      @converter = double("Docverter::Conversion").as_null_object
    end

    it 'should assign the other file to the converter' do
      @fd.stub(:download).and_return({'some/template.html' => '/tmp/xyz/templateXYZ.html'})
      @converter.should_receive(:template=).with('templateXYZ.html')
      fake_converter( template: "some/template.html").run 
    end

    it 'should assign the multiple files to the converter' do
      @converter.should_receive(:template=).with(["template.html", "other.html"])
      fake_converter( template: ["one/template.html", "two/other.html"]).run
    end

    it 'adds the file via :add_other_file' do
      @fd.stub(:download).and_return({'template.html' => '/tmp/xyz/templateXYZ.html'})
      @converter.should_receive(:add_other_file).with('/tmp/xyz/templateXYZ.html')

      fake_converter( template: "assets/template.html").run 
    end

    it 'can add generic files form :files' do
      @converter.should_not_receive(:files=)
      @fd.stub(:download).and_return({'template.html' => '/tmp/xyz/templateXYZ.html'})
      @converter.should_receive(:add_other_file).with("/tmp/xyz/templateXYZ.html")

      fake_converter( files: ["assets/template.html"]).run 
    end

    context ':css' do
      it 'attaches a default stylesheet' do
        @converter.should_receive(:css=).with(["theme.css", "custom.css"])
        @converter.should_receive(:add_other_file) do |path|
          expect(path).to match(/(theme|custom)\.css$/)
        end.twice

        fake_converter( files: []).run 
      end

      it 'doesnt break user :css files' do
        @converter.should_receive(:css=).with(["theme.css", "custom.css", "other_file.html"])
        fake_converter( css: "other_file.html", files: []).run 

        @converter.should_receive(:css=).with(["theme.css", "custom.css", "other.html", "file.html"])
        fake_converter( css: ["other.html", "file.html"], files: []).run 
      end

      it 'attaches pdf.css when converting to pdf' do
        @converter.should_receive(:css=).with(["theme.css", "custom.css", "pdf.css"])
        fake_converter( @converter, :pdf, files: []).run 
      end
    end
  end

end
