# MacOS/SystemProfiler.rb
# MacOS::SystemProfiler

# 20190831
# 0.2.0

# Description: This uses the built-in system_profiler command on MacOS to get access to the version numbers on any
# version of MacOS which has a system_profiler command and which returns results in a known format.

require 'Ordinal/Array'
require 'String/grep'
require 'Version'

module MacOS
  module SystemProfiler

    module_function

    def system_version
      common_output = `system_profiler SPSoftwareDataType`.force_encoding('UTF-8').grep(/System Version/).split(': ').last.split
      earlier_versions = common_output.fourth # OSX 10.4 to 10.9 at least
      later_versions = common_output.second # MacOS 10.14 at least
      Version.new(earlier_versions || later_versions)
    end

    def major_system_version
      system_version.major
    end

    def minor_system_version
      system_version.minor
    end

    def tiny_system_version
      system_version.tiny
    end

  end
end
