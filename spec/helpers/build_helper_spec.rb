require 'spec_helper'

describe BuildHelper do
  context '#build_message' do
    it 'cuts off a message at 25' do
      long_message = "a"*55

      output = message(long_message)
      expect(output.length).to eq(50)
    end

    it 'works with a nil or empty message' do
      expect(message(nil)).to eq("")
      expect(message("")).to eq("")
    end
  end

  context 'status_has_spinner?' do
    it 'is true for any /build/ status' do
      ['building pdf', 'Building Stuff', 'Uploading pdf'].each do |status|
        expect(status_has_spinner?(status)).to eq(true)
      end
    end

    it 'is true for queued' do
      expect(status_has_spinner?('queUed')).to eq(true)
    end

    it 'works with symbols' do
      expect(status_has_spinner?(:queued)).to eq(true)
    end
  end

  context '#build_status' do 
    def fa_icon(icon); icon end

    it 'returns a font awesome spinner' do
      expect(build_status('building pdf')).to match(/spinner/)
      expect(build_status('queued')).to match(/spinner/)
    end

    it 'does not return a spinner for un-loading tasks' do
      expect(build_status('completed')).not_to match(/spinner/)
    end
  end
end
