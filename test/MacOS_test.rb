require_relative './helper'
require 'MacOS'

describe MacOS do
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
