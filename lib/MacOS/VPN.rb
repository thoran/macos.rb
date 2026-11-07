# MacOS/VPN.rb
# MacOS::VPN

# Notes:
# 1. Taken from mercurial-0.4.3.

module MacOS
  module VPN
    def self.up?
      MacOS::IfConfig.up_interfaces.detect{|ifconfig| ifconfig.interface.match(/utun/)}
    end
  end
end
