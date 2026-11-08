require_relative './helper'
require 'open3'
require 'macos'

# The command each library sends, caught before it reaches the shell, so as none runs.
describe "the commands" do
  def sent_by(receiver, method, *args)
    sent = []
    receiver.stub(:`, ->(command){sent << command; ''}){receiver.send(method, *args)}
    sent
  end

  def captured_by(receiver, method, *args)
    sent = []
    Open3.stub(:capture3, ->(command){sent << command; ['', '', nil]}){receiver.send(method, *args)}
    sent
  end

  it "lists the hardware ports with networksetup" do
    _(sent_by(MacOS::HardwarePort, :output)).must_equal(['networksetup -listallhardwareports'])
  end

  it "lists the interfaces with ifconfig" do
    _(sent_by(MacOS::IfConfig, :output)).must_equal(['ifconfig -a'])
  end

  it "reads the software overview with system_profiler" do
    _(sent_by(MacOS::SystemProfiler, :system_profiler_output)).must_equal(['system_profiler SPSoftwareDataType'])
  end

  it "reads the Wi-Fi connection with system_profiler" do
    _(sent_by(MacOS::Apple80211, :system_profiler_airport)).must_equal(['system_profiler SPAirPortDataType'])
  end

  it "reads the Wi-Fi connection with airport, where it's there" do
    _(sent_by(MacOS::Apple80211, :airport_i)).must_equal(['/System/Library/PrivateFrameworks/Apple80211.framework/Resources/airport -I'])
  end

  it "lists the disks with diskutil" do
    _(sent_by(MacOS::DiskUtil, :xml_volume_plist)).must_equal(['diskutil list -plist'])
  end

  it "asks security for a generic password" do
    _(captured_by(MacOS::Keychain, :find_generic_password, 'ExampleNet')).must_equal(['security find-generic-password -ga ExampleNet'])
  end

  it "asks system_profiler for the USB devices" do
    _(captured_by(MacOS::USBFlashDrive, :raw_system_profiler_output)).must_equal(['system_profiler SPUSBDataType'])
  end
end
