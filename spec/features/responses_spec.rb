# frozen_string_literal: true

require 'antlers'

dirload(File.join(Dir.pwd, 'spec/fixtures'))

RSpec.describe 'Responses' do
  it 'redirects with a returned redirect, and sends the cookies the node set' do
    response = Ruby::SessionNode.post.response

    expect(response.status).to eq(303)
    expect(response.headers['location']).to eq('/home')
    expect(response.headers['set-cookie']).to eq(['session=a+b; Path=/; Max-Age=3600; HttpOnly; Secure; SameSite=Lax'])
  end

  it 'sends the cookies the node set with its body' do
    response = Ruby::SessionNode.get.response

    expect(response.body.read).to eq('page')
    expect(response.headers['content-type']).to eq('text/html')
    expect(response.headers['set-cookie']).to eq(['theme=dark; Path=/; SameSite=Strict'])
  end

  it 'sends the cookies the node set with a status' do
    response = Ruby::SessionNode.delete.response

    expect(response.status).to eq(204)
    expect(response.headers['set-cookie']).to eq(['session=; Path=/; Max-Age=0; HttpOnly; Secure; SameSite=Lax'])
  end

  it 'sends a returned hash or array as JSON, with the headers and cookies the node added' do
    response = Ruby::DataNode.get.response

    expect([response.status, response.headers['content-type'], response.body.read])
      .to eq([200, 'application/json', '{"recipes":["Rye"],"count":1}'])
    expect([response.headers['cache-control'], response.headers['set-cookie']])
      .to eq([['public', 'max-age=60'], ['seen=yes; Path=/; Secure; SameSite=Lax']])
    expect(Ruby::DataNode.put.response.body.read).to eq('[1,2]')
  end

  it 'sends returned text with the content type the node added' do
    response = Ruby::DataNode.patch.response

    expect([response.headers['content-type'], response.body.read]).to eq(['text/plain', 'User-agent: *'])
  end

  it 'sends a returned response as it is, with its own headers and the cookies the node set' do
    response = Ruby::DataNode.post.response

    expect([response.status, response.headers['content-type'], response.headers['cache-control'], response.body.read])
      .to eq([201, 'text/plain', ['no-store'], 'made'])
    expect(response.headers['set-cookie']).to eq(['seen=yes; Path=/; Secure; SameSite=Lax'])
  end

  it 'refuses an unknown SameSite' do
    expect { Low::Responses::Cookie.new(name: 'a', value: 'b', same_site: 'Loose') }.to raise_error(ArgumentError)
  end

  it "adds a JSON response and one the action made itself to the request's event tree, like an HTML one" do
    pool = Providers['low.event.pool']
    responses = [Ruby::DataNode.put, Ruby::DataNode.post]
    # By identity, as events of the same class are equal.
    expect(responses.map { |response| pool.current_event_tree(event: response).sequence.any? { it.equal?(response) } })
      .to eq([true, true])
  end
end
