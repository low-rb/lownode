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

    context 'with status event' do
      let(:event) { Low::Events::StatusEvent.new(status: Low::Types::Status[404], request: nil) }

      it 'responds with the status code' do
        response = Ruby::StatusNode.render(event:).response

        expect(response.status).to eq(404)
        expect(response.body.read).to eq('not found')
      end
    end

    context 'without status event' do
      it 'responds with 200' do
        expect(Ruby::Node.render.response.status).to eq(200)
      end
    end

    context 'with keywords' do
      it 'sends initialize and render only the keywords each takes' do
        expect(Ruby::KeywordNode.render(limit: 3, suffix: '!').response.body.read).to eq('3!')
      end

      it 'sends optional keywords' do
        expect(Ruby::KeywordNode.render(suffix: '?').response.body.read).to eq('5?')
      end

      it 'ignores keywords neither takes' do
        expect(Ruby::Node.render(limit: 3).response.body.read).to eq('node')
      end
    end

    context 'when parent' do
      it 'renders child' do
        expect(RBX::ParentNode.render.response.body.read).to eq('<html><p>I&#39;m a child</p></html>')
      end
    end
  end
end
