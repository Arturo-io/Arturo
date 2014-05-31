require 'spec_helper'

describe ApplicationHelper do
  it 'menu_active_class is active' do
    expect(self).to receive(:controller_name).and_return('main')
    expect(menu_active_class('main')).to eq('active')
  end

  it 'menu_active_class is inactive' do
    expect(self).to receive(:controller_name).and_return('other')
    expect(menu_active_class('main')).to eq('inactive')
  end

end
 
