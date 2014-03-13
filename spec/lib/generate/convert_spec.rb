require 'spec_helper'

describe Generate::Convert do
  let(:subject) { Generate::Convert }

  before do
    @fd = double("Github::FileListDownload").as_null_object
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

  context 'other files' do
    def fake_converter(double = @converter, options)
      Docverter::Conversion
        .should_receive(:new)
        .and_return(double)

      options[:file_list_download] =  @fd
      subject.new("#raw markdown", :html, options)
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
        @converter.should_receive(:css=).with(["theme.css"])
        @converter.should_receive(:add_other_file) do |path|
          expect(path).to match(/theme\.css$/)
        end

        @fd.stub(:download).and_return({})
        fake_converter( files: []).run 
      end

      it 'doesnt break user :css files' do
        @fd.stub(:download).and_return({})

        @converter.should_receive(:css=).with(["other_file.html", "theme.css"])
        fake_converter( css: "other_file.html", files: []).run 

        @converter.should_receive(:css=).with(["other.html", "file.html", "theme.css"])
        fake_converter( css: ["other.html", "file.html"], files: []).run 
      end
    end

    context 'private' do
      context '#find_path_key' do
        it 'can find the key from a hash' do
          hash ={ some_option: "szy", css: "stylesheet.css", other: "values"}
          expect(fake_converter({}).send(:find_path_key, hash, "stylesheet.css")).to eq(:css)

          hash ={ some_option: "szy", css: ["a.md", "stylesheet.css"], other: true}
          expect(fake_converter({}).send(:find_path_key, hash, "stylesheet.css")).to eq(:css)
          
        end
      end
    end

  end


end
