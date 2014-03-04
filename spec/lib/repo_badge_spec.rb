require 'spec_helper'

describe RepoBadge do
  let(:subject)  { RepoBadge }
  let(:base_url) { "http://arturo-badges.herokuapp.com/badge/" }


  it 'can create a repo URL from a build' do
    build = Build.new(ended_at: Time.parse("2000/02/01"))
    badge = subject.new(build)
    expect(badge.url).to eq("#{base_url}build-2000/02/01-brightgreen.png")
  end

end
