require 'spec_helper'

describe Pusher do
  it 'sets the Pusher params correctly' do
    expect(Pusher.app_id).to eq('none')
    expect(Pusher.key).to    eq('none')
    expect(Pusher.secret).to eq('none')
  end
end
