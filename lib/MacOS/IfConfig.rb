# OSX/IfConfig.rb
# OSX::IfConfig

# 20190828
# 0.3.0

# Changes since 0.2:
# 1. /OSX/MacOS/

require 'Thoran/String/Captures/captures'

module MacOS
  class IfConfig

    def new(output = nil)
      @output = output
    end

    def interfaces
      parse.keys
    end

    def active_interfaces
      parse.select do |interface, details|
        details.any?{|detail| detail =~ /status: active/}
      end.keys
    end

    private

    def output
      @output || `ifconfig -a`
    end

    def parse
      interfaces = {}
      interface = nil
      output.each_line do |line|
        if line =~ /^\t/
          interfaces[interface] << line.sub(/^\t/, '')
        else
          interface, rest_of_line = line.captures(/^(.+?): (.+)$/)
          interfaces[interface] = [rest_of_line]
        end
      end
      interfaces
    end

  end
end

if __FILE__ == $0
  require 'pp'
  ic = MacOS::IfConfig.new
  pp ic.send(:parse)
  ic.interfaces
  ic.active_interfaces
end
