# MacOS/IfConfig.rb
# MacOS::IfConfig

# 20191120, 21
# 0.3.1

# Changes since 0.2:
# 1. /OSX/MacOS/
# 0/1
# 2. /new()/initialize()/ (Really!? I did that!?)
# 3. Changed the self-run block to use p instead of pp.

require 'Thoran/String/Captures/captures'

module MacOS
  class IfConfig

    def initialize(output = nil)
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
  ifconfig = MacOS::IfConfig.new
  p ifconfig.send(:parse)
  p ifconfig.interfaces
  p ifconfig.active_interfaces
end
