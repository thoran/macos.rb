require_relative './helper'
require 'MacOS/VERSION'

describe 'macos.rb.gemspec' do
  # Loaded and validated from the gem's own directory, as gem build does, so as neither depends on where the tests run.
  let(:root){File.expand_path('..', __dir__)}
  let(:spec){Dir.chdir(root){Gem::Specification.load('macos.rb.gemspec')}}

  it "is a valid specification" do
    _(Dir.chdir(root){spec.validate}).must_equal(true)
  end

  it "is named macos.rb" do
    _(spec.name).must_equal('macos.rb')
  end

  it "does not pin a date" do
    _(spec.date).must_equal(Gem::Specification.new.date)
  end

  it "takes its version from MacOS::VERSION" do
    _(spec.version.to_s).must_equal(MacOS::VERSION)
  end

  it "declares its runtime dependencies" do
    _(spec.runtime_dependencies.map(&:name).sort).must_equal(%w{CFPropertyList plist})
  end

  it "declares its development dependencies" do
    _(spec.development_dependencies.map(&:name).sort).must_equal(%w{minitest minitest-mock rake})
  end

  it "ships the gemspec which names it, its Rakefile, and every library" do
    _(spec.files).must_include('macos.rb.gemspec')
    _(spec.files).must_include('Rakefile')
    _(spec.files).must_include('lib/MacOS.rb')
    _(spec.files).must_include('lib/Version.rb')
  end

  it "ships the tests with their fixtures" do
    _(spec.files).must_include('test/helper.rb')
    _(spec.files).must_include('test/fixtures/ifconfig-a.txt')
  end

  it "links the homepage and each metadata link to the repository" do
    links = [spec.homepage] + spec.metadata.values
    _(spec.metadata.keys.sort).must_equal(%w{bug_tracker_uri changelog_uri documentation_uri source_code_uri})
    links.each{|link| _(link).must_match(%r{\Ahttps://github\.com/thoran/macos\.rb(/|\z)})}
  end
end
