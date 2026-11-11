require_relative './helper'
require 'macos'

describe MacOS do
  # require 'macos' reads lib/macos.rb, the load file named after the gem. A capitalised load file answers that only on a
  # case-insensitive filesystem. Dir.entries reports the name as stored, so this asks what a case-sensitive one would.
  it "is loaded from the lowercase file the gem's name asks for" do
    _(Dir.entries(File.expand_path('../lib', __dir__))).must_include('macos.rb')
  end

  it "loads every library" do
    %w{
      Apple80211 Applications Defaults Defaults::ComAppleDock Defaults::NSGlobalDomain::NSUserKeyEquivalents DiskUtil Dmg
      HardwarePort IfConfig Keychain LaunchControl SystemProfiler USBFlashDrive Users VERSION VPN Voice
    }.each{|name| _(MacOS.const_get(name)).wont_be_nil}
  end

  def with_output(output = fixture('system_profiler-SPSoftwareDataType.json'), &block)
    MacOS::SystemProfiler.stub(:system_profiler_output, output, &block)
  end

  it "gives the system's version, as a Version" do
    with_output do
      _(MacOS.version).must_be_instance_of(Version)
      _(MacOS.version.to_s).must_equal('15.8.1')
      _(MacOS.version.major).must_equal('15')
    end
  end

  it "gives the version of an older OS X" do
    with_output('{"SPSoftwareDataType": [{"os_version": "Mac OS X 10.9.5 (13F34)"}]}') do
      _(MacOS.version.to_s).must_equal('10.9.5')
    end
  end

  it "gives the kernel's name, and its version as a Version" do
    with_output do
      _(MacOS.kernel_name).must_equal('Darwin')
      _(MacOS.kernel_version).must_be_instance_of(Version)
      _(MacOS.kernel_version.to_s).must_equal('24.6.0')
    end
  end
end
