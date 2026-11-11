# macos.rb
# MacOS

require 'MacOS/Apple80211'
require 'MacOS/Applications'
require 'MacOS/Defaults'
require 'MacOS/Defaults/ComAppleDock'
require 'MacOS/Defaults/NSGlobalDomain/NSUserKeyEquivalents'
require 'MacOS/DiskUtil'
require 'MacOS/Dmg'
require 'MacOS/HardwarePort'
require 'MacOS/IfConfig'
require 'MacOS/Keychain'
require 'MacOS/LaunchControl'
require 'MacOS/SystemProfiler'
require 'MacOS/USBFlashDrive'
require 'MacOS/Users'
require 'MacOS/VERSION'
require 'MacOS/VPN'
require 'MacOS/Voice'
require 'Version'

module MacOS
  module_function

  # The version in System Version, as 15.8.1 in macOS 15.8.1 (24H32), or 10.9.5 in Mac OS X 10.9.5 (13F34).
  def version
    system_version = MacOS::SystemProfiler.system_version
    Version.new(system_version.split[3] || system_version.split[1])
  end

  # The name in Kernel Version, as Darwin in Darwin 24.6.0.
  def kernel_name
    MacOS::SystemProfiler.kernel_version.split.first
  end

  # The version in Kernel Version, as 24.6.0 in Darwin 24.6.0.
  def kernel_version
    Version.new(MacOS::SystemProfiler.kernel_version.split.last)
  end
end
