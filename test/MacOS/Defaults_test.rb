require_relative '../helper'
require 'tmpdir'
require 'MacOS/Defaults'

describe MacOS::Defaults do
  def with_domains(&block)
    MacOS::Defaults.stub(:`, fixture('defaults-domains.txt'), &block)
  end

  # Stands in for MacOS::Defaults.new, making Defaults whose named methods only record the calls made on them.
  def recorder(calls, *methods)
    ->(domain:) do
      defaults = MacOS::Defaults.allocate
      defaults.send(:initialize, domain: domain)
      methods.each{|method| defaults.define_singleton_method(method){|*args| calls << [domain, method, *args]}}
      defaults
    end
  end

  describe ".domains" do
    it "lists every domain" do
      with_domains do
        _(MacOS::Defaults.domains).must_equal(%w{com.apple.dock com.apple.finder com.apple.Safari})
      end
    end

    it "makes a Defaults for each" do
      with_domains do
        _(MacOS::Defaults.all.map{|defaults| defaults.instance_variable_get(:@domain)}).must_equal(%w{com.apple.dock com.apple.finder com.apple.Safari})
      end
    end
  end

  describe "a domain" do
    it "is valid where defaults lists it, or where it's the global domain" do
      with_domains do
        _(MacOS::Defaults.new(domain: 'com.apple.dock').domain_valid?).must_equal(true)
        _(MacOS::Defaults.new(domain: '-globalDomain').domain_valid?).must_equal(true)
        _(MacOS::Defaults.new(domain: 'com.example.nowhere').domain_valid?).must_equal(false)
      end
    end

    it "knows whether it's the global domain" do
      _(MacOS::Defaults.new(domain: '-globalDomain').global_domain?).must_equal(true)
      _(MacOS::Defaults.new(domain: 'com.apple.dock').global_domain?).must_equal(false)
    end
  end

  describe "exporting and importing" do
    it "exports a valid domain to a plist file" do
      commands = []
      MacOS::Defaults.stub(:domains, %w{com.apple.dock}) do
        defaults = MacOS::Defaults.new(domain: 'com.apple.dock')
        defaults.stub(:`, ->(command){commands << command; ''}){_(defaults.export).must_equal(true)}
      end
      _(commands).must_equal(['defaults export com.apple.dock /tmp/com.apple.dock.plist'])
    end

    it "won't export a domain defaults doesn't know" do
      MacOS::Defaults.stub(:domains, []) do
        _{MacOS::Defaults.new(domain: 'com.example.nowhere').export}.must_raise(RuntimeError)
      end
    end

    it "won't import a domain without its plist file" do
      _{MacOS::Defaults.new(domain: 'com.example.nowhere').import}.must_raise(RuntimeError)
    end

    it "exports and imports every domain in bulk" do
      calls = []
      MacOS::Defaults.stub(:domains, %w{com.apple.dock com.apple.finder}) do
        MacOS::Defaults.stub(:new, recorder(calls, :export, :import)) do
          MacOS::Defaults.bulk_export_to_plist_files
          MacOS::Defaults.bulk_import_from_plist_files
        end
      end
      _(calls).must_equal([['com.apple.dock', :export], ['com.apple.finder', :export], ['com.apple.dock', :import], ['com.apple.finder', :import]])
    end
  end

  describe "from YAML" do
    let(:attributes){[{'autohide' => true}, {'tilesize' => 48}, {'scale' => 0.5}, {'orientation' => 'bottom'}, {'persistent-apps' => ['/Applications/Example.app']}]}

    it "writes each attribute, typed by its value" do
      defaults = MacOS::Defaults.new(domain: 'com.apple.dock')
      commands = commands_run_by(defaults){_(defaults.from_yaml(attributes)).must_equal(true)}
      _(commands).must_equal([
        %w{defaults write com.apple.dock autohide -bool true},
        %w{defaults write com.apple.dock tilesize -int 48},
        %w{defaults write com.apple.dock scale -float 0.5},
        %w{defaults write com.apple.dock orientation -string bottom},
        %w{defaults write com.apple.dock persistent-apps -array /Applications/Example.app},
      ])
    end

    it "is false where a write fails" do
      defaults = MacOS::Defaults.new(domain: 'com.apple.dock')
      defaults.stub(:system, false) do
        _(defaults.from_yaml([{'autohide' => true}])).must_equal(false)
      end
    end

    it "writes a Hash as a dictionary" do
      defaults = MacOS::Defaults.new(domain: 'com.apple.dock')
      commands = commands_run_by(defaults){defaults.from_yaml([{'example-dict' => {'size' => 48, 'shown' => true}}])}
      _(commands).must_equal([%w{defaults write com.apple.dock example-dict -dict size 48 shown true}])
    end

    it "reads what to_yaml writes" do
      written = MacOS::Defaults.new(domain: 'com.apple.dock')
      yaml = written.stub(:to_h, {'autohide' => true, 'tilesize' => 48}){written.to_yaml}
      _(YAML.safe_load(yaml)['com.apple.dock']).must_equal([{'autohide' => true}, {'tilesize' => 48}])
    end

    it "writes each domain a YAML file gives" do
      Dir.mktmpdir do |directory|
        path = File.join(directory, 'defaults.yml')
        File.write(path, {'com.apple.dock' => [{'autohide' => true}], 'com.apple.finder' => [{'ShowPathbar' => true}]}.to_yaml)
        calls = []
        MacOS::Defaults.stub(:new, recorder(calls, :from_yaml)){MacOS::Defaults.from_yaml(path)}
        _(calls).must_equal([['com.apple.dock', :from_yaml, [{'autohide' => true}]], ['com.apple.finder', :from_yaml, [{'ShowPathbar' => true}]]])
      end
    end

    it "reads DEFAULT_YAML_FILENAME where it's given no file" do
      loaded = []
      YAML.stub(:load_file, ->(path){loaded << path; {}}){MacOS::Defaults.from_yaml}
      _(loaded).must_equal([MacOS::Defaults::DEFAULT_YAML_FILENAME])
    end
  end

  describe "#to_h" do
    it "reads the domain's exported plist file" do
      domain = "com.example.macos-rb-test-#{Process.pid}"
      path = File.join(MacOS::Defaults::DEFAULT_PLIST_DIRECTORY, "#{domain}.plist")
      plist = CFPropertyList::List.new
      plist.value = CFPropertyList.guess('autohide' => true, 'tilesize' => 48)
      plist.save(path, CFPropertyList::List::FORMAT_XML)
      _(MacOS::Defaults.new(domain: domain).to_h).must_equal('autohide' => true, 'tilesize' => 48)
    ensure
      File.delete(path) if path && File.exist?(path)
    end
  end
end
