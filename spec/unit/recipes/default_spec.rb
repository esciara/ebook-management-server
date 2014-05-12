# encoding: UTF-8
require 'spec_helper'

describe 'ebook-management-server::default' do
  let(:chef_run) do
    runner = ChefSpec::Runner.new(
      log_level: :error
    )
    Chef::Config.force_logger true
    runner.converge('recipe[ebook-management-server::default]')
  end

  it 'should do something' do
    # pending
  end
end
