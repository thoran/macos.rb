# macos.rb

## Description

Do macOS stuff from Ruby.

* [MacOS::Apple80211](#macosapple80211): Wi-Fi
* [MacOS::Applications](#macosapplications): applications
* [MacOS::Defaults](#macosdefaults): defaults
* [MacOS::Defaults::ComAppleDock](#macosdefaultscomappledock): the Dock
* [MacOS::Defaults::NSGlobalDomain::NSUserKeyEquivalents](#macosdefaultsnsglobaldomainnsuserkeyequivalents): keyboard shortcuts
* [MacOS::DiskUtil](#macosdiskutil): disks
* [MacOS::Dmg](#macosdmg): disk images
* [MacOS::HardwarePort](#macoshardwareport): hardware ports
* [MacOS::IfConfig](#macosifconfig): network interfaces
* [MacOS::Keychain](#macoskeychain): the keychain
* [MacOS::LaunchControl](#macoslaunchcontrol): launchd
* [MacOS::SystemProfiler](#macossystemprofiler): the OS version, and the rest of the software overview
* [MacOS::USBFlashDrive](#macosusbflashdrive): USB flash drives
* [MacOS::Users](#macosusers): users
* [MacOS::Voice](#macosvoice): voices
* [MacOS::VPN](#macosvpn): VPNs

Each class wraps a command macOS provides, such as `ifconfig`, `networksetup`, `system_profiler`, `defaults` or `diskutil`, and gives back Ruby objects rather than text.

## Installation

Add this line to your application's Gemfile:

    gem 'macos.rb'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install macos.rb

## Usage

```ruby
require 'macos' # or require each class separately as per below, each needing nothing before it...

MacOS.version
# => #<Version @version_string="15.8.1">

MacOS.version.major
# => "15"

MacOS.version >= '14.0'
# => true
```

### MacOS::Apple80211

```ruby
require 'MacOS/Apple80211'

# From airport -I, or, from macOS 14.4 on, where airport reports nothing, from system_profiler SPAirPortDataType.
# That gives the channel and security in its own form, "36 (5GHz, 80MHz)" and "WPA2 Personal", and no SSID:
# macOS redacts the network's name from programs without location access.

MacOS::Apple80211.ssid
# => "ExampleNet"

MacOS::Apple80211.channel
# => "36,80"

MacOS::Apple80211.link_auth
# => "wpa2-psk"

MacOS::Apple80211.attributes
# => {"agrCtlRSSI" => "-52", ..., "SSID" => "ExampleNet", ..., "channel" => "36,80"}
```

### MacOS::Applications

```ruby
require 'MacOS/Applications'

MacOS::Applications.installed?('Safari') # in /System/Applications, /Applications or ~/Applications
# => true

MacOS::Applications.path_for('Safari')
# => "/Applications/Safari.app"

MacOS::Applications.start('Safari') # or .open, .launch or .run
# => true
```

### MacOS::Defaults

```ruby
require 'MacOS/Defaults'

MacOS::Defaults.domains
# => ["com.apple.dock", "com.apple.finder", "com.apple.Safari"]

defaults = MacOS::Defaults.new(domain: 'com.apple.dock')
# => #<MacOS::Defaults @domain="com.apple.dock">

defaults.domain_valid?
# => true

defaults.export # to /tmp/com.apple.dock.plist, which #to_h then reads
# => true

defaults.to_h
# => {"autohide" => true, "tilesize" => 48, ...}
```

### MacOS::Defaults::ComAppleDock

```ruby
require 'MacOS/Defaults/ComAppleDock'

MacOS::Defaults::ComAppleDock.read('autohide', 'tilesize')
# => {"autohide" => "yes", "tilesize" => 48}

MacOS::Defaults::ComAppleDock.read('persistent-apps')
# => {"persistent-apps" => ["/System/Applications/Mail.app/", "~/Applications/Example App.app"]}

MacOS::Defaults::ComAppleDock.load('persistent-apps' => ['/Applications/Safari.app'], 'autohide' => true)
# => {"persistent-apps" => ["/Applications/Safari.app"], "autohide" => true}
```

### MacOS::Defaults::NSGlobalDomain::NSUserKeyEquivalents

```ruby
require 'MacOS/Defaults/NSGlobalDomain/NSUserKeyEquivalents'

keys = MacOS::Defaults::NSGlobalDomain::NSUserKeyEquivalents

keys.key_code(%w{cmd alt left})
# => "@~\\UF702"

keys.assign_keys(%w{cmd alt left}, 'Previous Tab') # a keyboard shortcut for a menu item
# => true

keys.read_keys
# => [{keys: [:cmd, :alt, :left], menu_items: ["Previous Tab"]}, {keys: [:cmd, :shift, "d"], menu_items: ["Find Previous"]}]
```

### MacOS::DiskUtil

```ruby
require 'MacOS/DiskUtil'

MacOS::DiskUtil.volumes
# => [{device_id: "disk0s1", mount_point: nil, name: nil, size: 524288000}, ..., {device_id: "disk4s1", mount_point: "/Volumes/EXAMPLE", name: "EXAMPLE", size: 32006733824}]

MacOS::DiskUtil.free_bytes_for_volume_name('EXAMPLE')
# => 31990808576

MacOS::DiskUtil.free_bytes_for_device_id('disk4s1')
# => 31990808576
```

### MacOS::Dmg

```ruby
require 'MacOS/Dmg'

dmg = MacOS::Dmg.new(path_to_dmg: 'Example.dmg')
# => #<MacOS::Dmg @path_to_dmg="Example.dmg", @mount_point=nil, @package=nil>

dmg.install # mounts it, installs the one package on it with sudo installer, and unmounts it
# => true

dmg.mount_point # where hdiutil mounted the volume
# => "/Volumes/Example"
```

### MacOS::HardwarePort

```ruby
require 'MacOS/HardwarePort'

MacOS::HardwarePort.all
# => [#<MacOS::HardwarePort @hardware_port="Ethernet Adapter (en4)", @device="en4", @ethernet_address="00:00:5e:00:53:04">, ...]

hardware_port = MacOS::HardwarePort.find_by_name('Wi-Fi')
# => #<MacOS::HardwarePort @hardware_port="Wi-Fi", @device="en0", @ethernet_address="00:00:5e:00:53:08">

hardware_port.interface
# => "en0"
```

### MacOS::IfConfig

```ruby
require 'MacOS/IfConfig'

MacOS::IfConfig.interface_names
# => ["lo0", "gif0", "stf0", "en1", "en0", "awdl0", "bridge0", "utun0", "utun4"]

MacOS::IfConfig.up_interfaces_names # those active, or flagged UP, and with an address
# => ["lo0", "en0", "utun4"]

en0 = MacOS::IfConfig.find_by_interface('en0')
# => #<MacOS::IfConfig @broadcast_address="192.0.2.255", @flags=["UP", "BROADCAST", ...], @interface="en0", @ipv4_address="192.0.2.114", @mac_address="00:00:5e:00:53:02", @netmask="0xffffff00", @status="active">

en0.ipv4_address
# => "192.0.2.114"

en0.mac_address
# => "00:00:5e:00:53:02"

en0.up? # active, or flagged UP, and with an address
# => "192.0.2.114"

MacOS::IfConfig.all_matching(/\Autun/) # a Regexp, or a String matched literally
# => [#<MacOS::IfConfig @interface="utun0", ...>, #<MacOS::IfConfig @interface="utun4", ...>]

MacOS::IfConfig.bring_down_interface('utun4') # with sudo ifconfig
# => true
```

### MacOS::Keychain

```ruby
require 'MacOS/Keychain'

MacOS::Keychain.wifi_password('ExampleNet') # nil where the keychain has none
# => "example-password"
```

### MacOS::LaunchControl

```ruby
require 'MacOS/LaunchControl'

launch_control = MacOS::LaunchControl.new('/Library/LaunchAgents/com.example.agent.plist')
# => #<MacOS::LaunchControl @path_to_plist="/Library/LaunchAgents/com.example.agent.plist">

launch_control.load
# => true

launch_control.unload
# => true
```

### MacOS::SystemProfiler

```ruby
require 'MacOS/SystemProfiler'

MacOS::SystemProfiler.kernel_version
# => #<Version @version_string="24.6.0">

MacOS::SystemProfiler.boot_mode
# => "Normal"

MacOS::SystemProfiler.computer_name
# => "Example Mac"

MacOS::SystemProfiler.time_since_boot
# => "6 days, 2 hours, 34 minutes"
```

### MacOS::USBFlashDrive

```ruby
require 'MacOS/USBFlashDrive'

MacOS::USBFlashDrive.all_mount_points
# => ["/Volumes/EXAMPLE", "/Volumes/Example 2"]
```

### MacOS::Users

```ruby
require 'MacOS/Users'

MacOS::Users.all # the real users, without the system and service accounts
# => ["another", "example"]
```

### MacOS::Voice

```ruby
require 'MacOS/Voice'

MacOS::Voice.all # or .list
# => [#<MacOS::Voice @name="Albert", @localization="en_US", @description="Hello! My name is Albert.">, ...]

MacOS::Voice.random_voice
# => #<MacOS::Voice @name="Bad News", @localization="en_US", @description="Hello! My name is Bad News.">
```

### MacOS::VPN

```ruby
require 'MacOS/VPN'

MacOS::VPN.up? # the first tunnel interface which is up, if any
# => #<MacOS::IfConfig @interface="utun4", @ipv4_address="198.51.100.250", ...>
```

## Versions

Versions before 0.49.0 were reckoned when the library was put together, from its components' own versions; 0.50.0 is the first released as a gem. Each version carries the libraries it requires, at the versions current at its date.

## Tests

    $ bundle exec rake test

The tests never run the commands macOS provides. Each is given output captured from them, in `test/fixtures`, with its MAC addresses, IP addresses and names made anonymous.

## Contributing

1. Fork it (<https://github.com/thoran/macos.rb/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new pull request

## License

[MIT](LICENSE)
