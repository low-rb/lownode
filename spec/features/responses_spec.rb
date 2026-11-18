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

  it 'refuses an unknown SameSite' do
    expect { Low::Responses::Cookie.new(name: 'a', value: 'b', same_site: 'Loose') }.to raise_error(ArgumentError)
  end
end
