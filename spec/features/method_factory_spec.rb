# frozen_string_literal: true

require 'antlers'

dirload(File.join(Dir.pwd, 'spec/fixtures'))

RSpec.describe 'Method Factory' do
  describe '#render' do
    context 'without event' do
      it 'instantiates node and returns response' do
        expect(Ruby::Node.render.response.body.read).to eq('node')
      end

      context 'with RBX' do
        it 'instantiates node and returns response' do
          expect(RBX::Node.render.response.body.read).to eq('<html>node</html>')
        end
      end
    end

    context 'with event' do
      let(:event) { 'mock event' }

      it 'instantiates node, receives arg and returns response' do
        expect(Ruby::NodeWithEvent.render(event:).response.body.read).to eq('mock event')
      end

      context 'with RBX' do
        it 'instantiates node, receives arg and returns response' do
          expect(RBX::NodeWithEvent.render(event:).response.body.read).to eq('<html>mock event</html>')
        end
      end
    end

    context 'when parent' do
      it 'renders child' do
        expect(RBX::ParentNode.render.response.body.read).to eq('<html><p>I&#39;m a child</p></html>')
      end
    end
  end
end
