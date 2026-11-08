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

  it "gives the system's version" do
    MacOS::SystemProfiler.stub(:system_profiler_output, fixture('system_profiler-SPSoftwareDataType.txt')) do
      _(MacOS.version.to_s).must_equal('15.8.1')
    end
  end
end
