# frozen_string_literal: true

require_relative 'lib/version'

Gem::Specification.new do |spec|
  spec.name = 'lownode'
  spec.version = Low::Node::VERSION
  spec.authors = ['maedi']
  spec.email = ['maediprichard@gmail.com']

  spec.summary = 'Flexible building blocks'
  spec.homepage = 'https://github.com/low-rb/lownode'
  spec.required_ruby_version = '>= 3.3.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/low-rb/lownode/src/branch/main'

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir.glob('lib/**/*')
  end

  spec.require_paths = ['lib']
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }

  spec.add_dependency 'lowevent'
  spec.add_dependency 'lowloop' # TODO: Should not know anything about or use low loop.
  spec.add_dependency 'lowtype', '~> 1.0'

  spec.add_dependency 'antlers'
  spec.add_dependency 'observers'
end
