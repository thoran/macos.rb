# MacOS/IfConfig.rb
# MacOS::IfConfig

# 20200428
# 0.4.0

# Changes since 0.3:
# 0: Aligned MacOS::IfConfig more closely with MacOS::HardwarePort
# 1. ~ MacOS::IfConfig#parse --> MacOS::IfConfig.parse
# 2. ~ MacOS::IfConfig#interfaces --> MacOS::IfConfig.interfaces && now returns the same as parse.
# 2. ~ MacOS::IfConfig#output --> MacOS::IfConfig.output
# 3. ~ MacOS::IfConfig#active_interfaces --> MacOS::IfConfig.active_interfaces
# 4. + MacOS::IfConfig.interface_names (formerly MacOS::IfConfig#interfaces)
# 5. + MacOS::IfConfig.active_interfaces_names
# 6. + MacOS::IfConfig.mac_addresses
# 7. + MacOS::IfConfig.ipv4_addresses
# 8. + require 'Thoran/String/Capture/capture', so as to support the increased complexity in MacOS::IfConfig.parse.

require 'Thoran/String/Capture/capture'
require 'Thoran/String/Captures/captures'

module MacOS
  class IfConfig

    class << self

      def parse(output = nil)
        output ||= self.output
        @ifconfigs = []
        interface = nil
        output.each_line do |line|
          if line =~ /^\t/
            case line
            when /ether/
              @ifconfig.mac_address = line.capture(/ *ether (.+) $/)
            when /inet /
              if line.match(/broadcast/)
                @ifconfig.ipv4_address, @ifconfig.netmask, @ifconfig.broadcast_address = line.captures(/ *inet (\d+(?:\.\d+){3}) netmask (.+) broadcast (.+)$/)
              else
                @ifconfig.ipv4_address, @ifconfig.netmask = line.captures(/ *inet (\d+(?:\.\d+){3}) netmask (.+) $/)
              end
            when /status\:/
              @ifconfig.active = line.capture(/ *status: (.+)$/) == 'active'
            end
          else
            @ifconfigs << @ifconfig if @ifconfig
            @ifconfig = new
            @ifconfig.interface, _rest_of_line = line.captures(/^(.+?): (.+)$/)
          end
        end
        @ifconfigs
      end
      alias_method :all, :parse
      alias_method :interfaces, :parse

      def interface_names
        all.collect(&:interface_name)
      end

      def active_interfaces
        all.select(&:active?)
      end
      alias_method :active, :active_interfaces

      def active_interfaces_names
        all.select(&:active?).collect(&:interface_name)
      end

      def mac_addresses
        all.collect(&:mac_address).compact
      end
      alias_method :ethernet_addresses, :mac_addresses

      def ipv4_addresses
        all.collect(&:ipv4_address).compact
      end

      private

      def output
        `ifconfig -a`
      end

    end # class << self

    attr_accessor :interface
    attr_accessor :mac_address
    attr_accessor :ipv4_address, :netmask, :broadcast_address
    attr_accessor :active

    def initialize(interface: nil, mac_address: nil, ipv4_address: nil, netmask: nil, broadcast_address:nil, active: nil)
      @interface = interface
      @mac_address = mac_address
      @ipv4_address, @netmask, @broadcast_address = ipv4_address, netmask, broadcast_address
      @active = active
    end

    def interface_name
      @interface
    end
    alias_method :name, :interface_name

    def ethernet_address
      @mac_address
    end

    def active?
      @active
    end

  end
end

if __FILE__ == $0
  p MacOS::IfConfig.interfaces
  p MacOS::IfConfig.interface_names
  p MacOS::IfConfig.active_interfaces
  p MacOS::IfConfig.active_interfaces_names
  p MacOS::IfConfig.mac_addresses
  p MacOS::IfConfig.ipv4_addresses
end
