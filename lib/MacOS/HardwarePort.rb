# MacOS/Hardware.rb
# MacOS::Hardware

# 20190828
# 0.2.0

# Changes since 0.1:
# 1. /OSX/MacOS/

require 'Thoran/String/Captures/captures'

module MacOS
  class HardwarePort

    class << self

      def parse(output)
        hardware_ports = []
        hardware_port = nil
        output.each_line do |line|
          if line == "\n" || line == ""
            hardware_port = new
          else
            label, value = line.captures(/^(.+): (.+)/)
            case label
            when 'Hardware Port'; hardware_port.hardware_port = value
            when 'Device'; hardware_port.device = value
            when 'Ethernet Address'; hardware_port.ethernet_address = value
            end
          end
          hardware_ports << hardware_port
        end
        hardware_ports
      end

      def all
        parse(output)
      end

      def find_by_device(device)
        all.detect{|hardware_port| hardware_port.device == device}
      end

      private

      def output
        `networksetup -listallhardwareports`
      end

    end # class << self

    attr_accessor :hardware_port
    attr_accessor :device
    attr_accessor :ethernet_address

    def new(hardware_port:, device:, ethernet_address:)
      @hardware_port = hardware_port
      @device = device
      @ethernet_address = ethernet_address
    end

    def name
      @hardware_port
    end

  end
end

if __FILE__ == $0
  p hardware_ports = MacOS::HardwarePort.all
  p en4 = MacOS::HardwarePort.find_by_device('en4')
end
