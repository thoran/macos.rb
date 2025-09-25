# MacOS/VPN.rb
# MacOS/VPN.rb

# 20250925
# 0.0.0

# Notes:
# 1. Taken from mercurial-0.4.3.

module MacOS
  module VPN
    def self.up?
      MacOS::IfConfig.up_interfaces.detect{|ifconfig| ifconfig.interface.match(/utun/)}
    end
  end
end
