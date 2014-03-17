require 'spec_helper'

describe Transform::NewLine do

  it 'appends a new line to the input' do
    transform = Transform::NewLine.execute("some text", nil)
    expect(transform).to eq("some text\n")
  end
end
