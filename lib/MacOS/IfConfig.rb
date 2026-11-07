# MacOS/IfConfig.rb
# MacOS::IfConfig

module MacOS
  class IfConfig
    class << self
      def parse(output = nil)
        output ||= self.output
        ifconfigs = []
        ifconfig = nil
        output.each_line do |line|
          if line =~ /^\t/
            case line
            when /ether/
              ifconfig.mac_address = line[/ *ether (.+?) ?$/, 1]
            when /inet /
              if line.match(/broadcast/)
                ifconfig.ipv4_address, ifconfig.netmask, ifconfig.broadcast_address = line.match(/ *inet (\d+(?:\.\d+){3}) netmask (.+) broadcast (.+)$/)&.captures
              elsif line.match(/-->/)
                ipv4_address_from, ipv4_address_to, ifconfig.netmask = line.match(/inet (.+) --> (.+) netmask (.+)$/)&.captures
                ifconfig.ipv4_address = ipv4_address_from
              else
                ifconfig.ipv4_address, ifconfig.netmask = line.match(/ *inet (\d+(?:\.\d+){3}) netmask (.+?) ?$/)&.captures
              end
            when /status\:/
              ifconfig.status = line[/ *status: (.+)$/, 1]
            end
          else
            ifconfigs << ifconfig if ifconfig
            ifconfig = new
            ifconfig.interface, rest_of_line = line.match(/^(.+?): (.+)$/)&.captures
            if rest_of_line =~ /flags=\w+<([^>]+)>/
              ifconfig.flags = $1.split(',')
            end
          end
        end
        ifconfigs << ifconfig if ifconfig
        ifconfigs
      end
      alias_method :all, :parse
      alias_method :interfaces, :parse
      alias_method :all_interfaces, :parse

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

      def inactive_interfaces
        all.select(&:inactive?)
      end
      alias_method :inactive, :inactive_interfaces

      def inactive_interfaces_names
        all.select(&:inactive?).collect(&:interface_name)
      end

      def up_interfaces
        all.select(&:up?)
      end
      alias_method :up, :up_interfaces

      def up_interfaces_names
        all.select(&:up?).collect(&:interface_name)
      end

      def mac_addresses
        all.collect(&:mac_address).compact
      end
      alias_method :ethernet_addresses, :mac_addresses

      def ipv4_addresses
        all.collect(&:ipv4_address).compact
      end

      def find_by_interface(interface)
        all.find{|ifconfig| ifconfig.interface == interface}
      end

      def find_by_mac_address(mac_address)
        all.find{|ifconfig| ifconfig.mac_address == mac_address}
      end

      def find_by_ipv4_address(ipv4_address)
        all.find{|ifconfig| ifconfig.ipv4_address == ipv4_address}
      end

      def all_matching(pattern)
        pattern = Regexp.union(pattern)
        all.select{|ifconfig| ifconfig.name =~ pattern}
      end

      def bring_down_interface(interface_name)
        system('sudo', 'ifconfig', interface_name, 'down', exception: true)
      end

      def bring_down_matching_interfaces(pattern)
        matching_interfaces = all_matching(pattern).select(&:up?)
        matching_interfaces.each do |ifconfig|
          bring_down_interface(ifconfig.name)
        end
        matching_interfaces.map(&:name)
      end

      def destroy_interface(interface_name)
        system('sudo', 'ifconfig', interface_name, 'destroy', exception: true)
      end

      private

      def output
        `ifconfig -a`
      end
    end # class << self

    attr_accessor(
      :broadcast_address,
      :flags,
      :interface,
      :ipv4_address,
      :mac_address,
      :netmask,
      :status
    )

    def initialize(
      broadcast_address: nil,
      flags: nil,
      interface: nil,
      ipv4_address: nil,
      mac_address: nil,
      netmask: nil,
      status: nil
    )
      @broadcast_address = broadcast_address
      @flags = flags
      @interface = interface
      @ipv4_address = ipv4_address
      @mac_address = mac_address
      @netmask = netmask
      @status = status
    end

    def interface_name
      @interface
    end
    alias_method :name, :interface_name

    def ethernet_address
      @mac_address
    end

    def active?
      @status == 'active'
    end

    def inactive?
      @status == 'inactive'
    end

    # For interfaces with status field (physical), check active status and IP address.
    # For interfaces with flags only (virtual), check UP flag and IP address.
    def up?
      if @status
        active? && @ipv4_address
      else
        (@flags && @flags.include?('UP')) && @ipv4_address
      end
    end

    def virtual?
      @interface =~ /^(utun|awdl|llw|lo|bridge|gif|stf)\d*/
    end
  end
end

if __FILE__ == $0
  require 'pp'
  pp MacOS::IfConfig.interfaces
  p MacOS::IfConfig.interface_names
  p MacOS::IfConfig.active_interfaces
  p MacOS::IfConfig.active_interfaces_names
  p MacOS::IfConfig.inactive_interfaces
  p MacOS::IfConfig.inactive_interfaces_names
  p MacOS::IfConfig.up_interfaces
  p MacOS::IfConfig.up_interfaces_names
  p MacOS::IfConfig.mac_addresses
  p MacOS::IfConfig.ipv4_addresses
  p MacOS::IfConfig.find_by_interface('en0')
end
