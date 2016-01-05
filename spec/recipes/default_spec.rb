
require 'spec_helper'

describe "mediawiki::default" do
  
  let(:chef_run) do
    ChefSpec::SoloRunner.new do |node|
      node.set['cookbook']['attribute'] = 'hello'
    end.converge(described_recipe)
  end

  it 'is sane' do
    true.should eql true
  end
    
end

