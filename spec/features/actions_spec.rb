# frozen_string_literal: true

require 'antlers'

dirload(File.join(Dir.pwd, 'spec/fixtures'))

RSpec.describe 'Actions' do
  before do
    Ruby::ActionNode.initialized = 0
  end

  it 'defines every action as a class method' do
    expect(LowNode::ACTIONS.all? { |action| Ruby::PlainNode.respond_to?(action) }).to be(true)
  end

  it 'calls the instance method for an action' do
    expect(Ruby::ActionNode.receive(event: 'event').response.body.read).to eq('received event')
  end

  context 'with include Controller' do
    it 'defines every HTTP verb action as a class method' do
      expect(LowNode::CONTROLLER_ACTIONS.all? { |action| Ruby::ActionNode.respond_to?(action) }).to be(true)
    end

    it 'calls the instance method for a HTTP verb action' do
      expect(Ruby::ActionNode.get.response.body.read).to eq('got')
    end
  end

  context 'without include Controller' do
    it 'does not define the HTTP verb actions, so observers skip them' do
      expect(LowNode::CONTROLLER_ACTIONS.none? { |action| Ruby::PlainNode.respond_to?(action) }).to be(true)
    end
  end

  it 'sends the action only the keywords it takes' do
    expect(Ruby::ActionNode.post(event: 'event', limit: 3).response.body.read).to eq('posted event')
  end

  it 'responds with the status of a returned status' do
    response = Ruby::ActionNode.put.response

    expect(response.status).to eq(204)
    expect(response.body).to be_nil
  end

  it 'returns a returned response event' do
    expect(Ruby::ActionNode.delete.response.body.read).to eq('node')
  end

  context 'when the node does not implement the action' do
    it 'returns nil without initializing the node' do
      expect([Ruby::ActionNode.render, Ruby::ActionNode.side_effect]).to eq([nil, nil])
      expect(Ruby::ActionNode.initialized).to eq(0)
    end

    it 'does not call a private method' do
      expect(Ruby::ActionNode.patch).to be_nil
      expect(Ruby::ActionNode.initialized).to eq(0)
    end
  end
end
