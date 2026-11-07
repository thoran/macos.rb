# MacOS.rb

# 20261107
# 0.1.0

# Changes since 0.0:
# -/0: Require every library, and take in MacOS.version.
# 1. + require 'MacOS/Apple80211', 'MacOS/Applications', 'MacOS/Defaults/ComAppleDock', 'MacOS/Defaults/NSGlobalDomain/NSUserKeyEquivalents', 'MacOS/DiskUtil', 'MacOS/Keychain', 'MacOS/USBFlashDrive', 'MacOS/Users', 'MacOS/Voice' and 'MacOS/VPN'
# 2. - require 'MacOS/Version'
# 3. + MacOS.version, from MacOS/Version.rb 0.1.0.

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
require 'MacOS/VPN'
require 'MacOS/Voice'

module MacOS
  module_function

  def version
    MacOS::SystemProfiler.system_version
  end
end
