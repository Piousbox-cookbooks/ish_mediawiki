
require 'spec_helper'

describe "ish_mediawiki::default" do

  before :each do
    stubbed_data_bag = {
      :user => { :_default => 'some-user' },
      :aws_key => { :_default => 'some-aws-key' },
      :aws_secret => { :_default => 'some-aws-secret' },
      :databases => { :_default => { :username => 'some-username' } },
      :mediawiki_version => { :_default => '2.6' },
      :restore_name => { :_default => 'some-restore-name' },
      :domains => { :_default => [] }
    }
    stub_data_bag_item("apps", "wiki_wasya").and_return( stubbed_data_bag )
    stub_command("/usr/sbin/apache2 -t").and_return(true)
    stub_command("mysql -usome-username -p -h  -se'USE ;' 2>&1").and_return(true)
  end
  
  let(:chef_run) do
    ChefSpec::SoloRunner.new do |node|
      node.set['chef_environment'] = '_default'
      # node.set['cookbook']['attribute'] = 'hello'
    end.converge(described_recipe)
  end

  it 'installs apache' do
    expect(chef_run).to include_recipe("ish_apache::install_apache")
  end

  it 'installs packages' do
    %w{ awscli git }.each do |pkg|
      expect(chef_run).to install_package pkg
    end
  end
    
end

