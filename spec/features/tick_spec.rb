# frozen_string_literal: true

require 'antlers'

dirload(File.join(Dir.pwd, 'spec/fixtures'))

RSpec.describe 'Ticks' do
  it 'calls the instance method each time an interval the node observes is due, ignoring what it returns' do
    Ruby::TickNode.ticks = []
    expect([Ruby::TickNode.tick(event: 'interval'), Ruby::TickNode.ticks]).to eq([nil, ['interval']])
  end

  it "doesn't initialize a node that doesn't tick" do
    Ruby::ActionNode.initialized = 0
    Ruby::ActionNode.tick(event: 'interval')
    expect(Ruby::ActionNode.initialized).to eq(0)
  end
end
