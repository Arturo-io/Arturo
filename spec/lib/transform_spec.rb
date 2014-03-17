require 'spec_helper'


describe Transform do
  after { Transform.plugins = [] } 

  it 'executes transforms from registered plugins' do
    class Example;end
    class ExampleTwo;end
    Transform.plugins = [Example, ExampleTwo]

    expect(Example).to receive(:execute)
                        .with("start", nil)
                        .and_return("return_from_example")

    expect(ExampleTwo).to receive(:execute)
                            .with("return_from_example", nil)
                            .and_return("final")

    expect(Transform.execute("start")).to eq("final")
  end

  it 'returns the input when there are no plugins' do
    Transform.plugins = []
    expect(Transform.execute("start")).to eq("start")
  end

  it 'passes the caller to the plugins' do
    class Plugin
      def self.execute(input, from)
        "#{input} #{from}"
      end 
    end 

    class Caller; end 
    Transform.plugins = [Plugin]

    expect(Transform.execute("start", Caller)).to eq("start Caller")
  end

end
