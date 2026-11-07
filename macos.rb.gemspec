# macos.rb.gemspec

require_relative './lib/MacOS/VERSION'

class Gem::Specification
  def dependencies=(gems)
    gems.each{|gem| add_dependency(*gem)}
  end

  def development_dependencies=(gems)
    gems.each{|gem| add_development_dependency(*gem)}
  end
end

Gem::Specification.new do |spec|
  spec.name = 'macos.rb'
  spec.version = MacOS::VERSION

  spec.summary = "Work with macOS from Ruby."
  spec.description = "Work with macOS from Ruby: network interfaces and hardware ports, the system's version, defaults, disks and disk images, USB flash drives, applications, users, voices, the keychain and launchd."

  spec.author = 'thoran'
  spec.email = 'code@thoran.com'
  spec.homepage = 'https://github.com/thoran/macos.rb'
  spec.license = 'MIT'

  spec.metadata = {
    'bug_tracker_uri' => 'https://github.com/thoran/macos.rb/issues',
    'changelog_uri' => 'https://github.com/thoran/macos.rb/blob/master/CHANGELOG',
    'source_code_uri' => 'https://github.com/thoran/macos.rb',
    'documentation_uri' => 'https://github.com/thoran/macos.rb/blob/master/README.md',
  }

  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.7'

  spec.files = [
    'macos.rb.gemspec',
    Dir['lib/**/*.rb'],
    Dir['test/**/*.rb'],
    Dir['test/fixtures/*'],
    'CHANGELOG',
    'Gemfile',
    'LICENSE',
    'Rakefile',
    'README.md',
  ].flatten

  spec.dependencies = %w{
    CFPropertyList
    plist
  }

  spec.development_dependencies = %w{
    minitest
    minitest-mock
    rake
  }
end
