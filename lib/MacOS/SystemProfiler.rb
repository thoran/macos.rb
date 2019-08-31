# MacOS/SystemProfiler.rb
# MacOS::SystemProfiler

# 20190831
# 0.1.0

# Description: This uses the built-in system_profiler command on MacOS to get access to the version numbers on any
# version of MacOS which has a system_profiler command and which returns results in a known format.

require 'Ordinal/Array'
require 'String/grep'

module MacOS
  module SystemProfiler

    module_function

    def system_version
      common_output = `system_profiler SPSoftwareDataType`.force_encoding('UTF-8').grep(/System Version/).split(': ').last.split
      common_output.fourth || # OSX 10.4 to 10.9 at least
        common_output.second # MacOS 10.14 at least
    end

    def major_system_version
      system_version.split('.').first
    end

    def minor_system_version
      system_version.split('.').second
    end

    def tiny_system_version
      system_version.split('.').third
    end

  end
end
