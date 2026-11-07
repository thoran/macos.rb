# macos.rb

Work with macOS from Ruby: network interfaces and hardware ports, the system's version, defaults, disks and disk images, USB flash drives, applications, users, voices, the keychain and launchd.

Each part wraps the command macOS provides for it, such as `ifconfig`, `networksetup`, `system_profiler`, `defaults` or `diskutil`, and gives back Ruby objects rather than text.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'macos.rb'
```

And then execute:

```
$ bundle install
```

Or install it yourself as:

```
$ gem install macos.rb
```

## Usage

```ruby
require 'MacOS'
```

loads every part, or require only the parts you want, such as `require 'MacOS/IfConfig'`.

### Network interfaces and hardware ports

```ruby
MacOS::IfConfig.interface_names            # => ["lo0", "en0", "utun4", ...]
MacOS::IfConfig.up_interfaces_names        # those active, or flagged UP, and with an address
en0 = MacOS::IfConfig.find_by_interface('en0')
en0.ipv4_address                           # => "192.0.2.114"
en0.mac_address                            # => "00:00:5e:00:53:02"
MacOS::IfConfig.all_matching(/\Autun/)     # a Regexp, or a String matched literally

MacOS::HardwarePort.find_by_name('Wi-Fi').interface    # => "en0"

MacOS::VPN.up?                             # the first tunnel interface which is up, if any

MacOS::Apple80211.channel                  # the Wi-Fi connection's; also .ssid, .link_auth and .attributes
```

Apple80211 reads `airport -I`, and from macOS 14.4 on, where `airport` reports nothing, `system_profiler SPAirPortDataType`. That gives the channel and security in its own form, `"36 (5GHz, 80MHz)"` and `"WPA2 Personal"`, rather than airport's, and no SSID: macOS redacts the network's name from programs without location access.

### The system

```ruby
MacOS.version                              # a Version, which compares with strings: MacOS.version >= '14.0'
MacOS.version.major                        # => "15"
MacOS::SystemProfiler.kernel_version.to_s  # => "24.6.0"
MacOS::SystemProfiler.boot_mode            # => "Normal"
MacOS::SystemProfiler.time_since_boot      # => "6 days, 2 hours, 34 minutes"
```

### Defaults

```ruby
MacOS::Defaults.domains                    # every domain defaults knows
MacOS::Defaults.new(domain: 'com.apple.dock').export     # to a plist file, which #to_h then reads

MacOS::Defaults::ComAppleDock.read('autohide', 'tilesize')   # => {"autohide" => "yes", "tilesize" => 48}
MacOS::Defaults::ComAppleDock.load('persistent-apps' => ['/Applications/Safari.app'], 'autohide' => true)

keys = MacOS::Defaults::NSGlobalDomain::NSUserKeyEquivalents
keys.assign_keys(%w{cmd alt left}, 'Previous Tab')       # a keyboard shortcut for a menu item
keys.read_keys                             # => [{keys: [:cmd, :alt, :left], menu_items: ["Previous Tab"]}, ...]
```

### Disks, disk images and USB flash drives

```ruby
MacOS::DiskUtil.volumes                    # => [{device_id: "disk4s1", mount_point: "/Volumes/EXAMPLE", name: "EXAMPLE", size: ...}, ...]
MacOS::DiskUtil.free_bytes_for_volume_name('EXAMPLE')

MacOS::Dmg.new(path_to_dmg: 'Example-1.0.dmg', disk_image_name: 'Example-1.0.dmg', package: 'Example').install

MacOS::USBFlashDrive.all_mount_points      # => ["/Volumes/EXAMPLE", ...]
```

### Applications, users, voices, the keychain and launchd

```ruby
MacOS::Applications.installed?('Safari')   # in /System/Applications, /Applications or ~/Applications
MacOS::Applications.start('Safari')

MacOS::Users.all                           # the real users, without the system and service accounts

MacOS::Voice.list.map(&:name)              # every voice say knows
MacOS::Voice.random_voice

MacOS::Keychain.wifi_password('ExampleNet')            # nil where the keychain has none

MacOS::LaunchControl.new('/Library/LaunchAgents/com.example.agent.plist').load
```

Some of these change the system, and some ask for `sudo`: bringing interfaces down, installing from a disk image, writing defaults and loading launchd plists. Reading never does.

## Versions

Versions before 0.49.0 were reckoned when the library was put together, from its components' own versions; 0.50.0 is the first released as a gem. Each version carries the libraries it requires, at the versions current at its date.

## Tests

```
$ bundle exec rake test
```

The tests never run the commands macOS provides. Each is given output captured from them, in `test/fixtures`, with its MAC addresses, IP addresses and names made anonymous.

## Contributing

1. Fork it (https://github.com/thoran/macos.rb/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new pull request

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
