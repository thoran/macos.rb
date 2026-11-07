# MacOS/SystemProfiler.rb
# MacOS::SystemProfiler

# Description: This uses the built-in system_profiler command on MacOS to get access to the version numbers on any
# version of MacOS which has a system_profiler command and which returns results in a known format.

require 'Version'

module MacOS
  module SystemProfiler

    module_function

    def system_profiler_output
      `system_profiler SPSoftwareDataType`.force_encoding('UTF-8')
    end

    # The value system_profiler gives for a field, such as 'Boot Volume'.
    def field(name)
      system_profiler_output[/#{Regexp.escape(name)}: (?<value>.+)$/, :value]
    end
    private_class_method :field

    def system_version_data
      field('System Version')
    end

    def system_version_string
      earlier_versions = system_version_data.split[3] # OSX 10.4 to 10.9 at least
      later_versions = system_version_data.split[1] # MacOS 10.14 at least
      earlier_versions || later_versions
    end

    def system_version
      Version.new(system_version_string)
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

    def kernel_version_data
      field('Kernel Version')
    end

    def kernel_name
      kernel_version_data.split.first
    end

    def kernel_version_string
      kernel_version_data.split.last
    end

    def kernel_version
      Version.new(kernel_version_string)
    end

    def boot_volume_data
      field('Boot Volume')
    end
    alias_method :boot_volume_string, :boot_volume_data

    def boot_mode_data
      field('Boot Mode')
    end
    alias_method :boot_mode_string, :boot_volume_data
    alias_method :boot_mode, :boot_volume_data

    def computer_name_data
      field('Computer Name')
    end
    alias_method :computer_name_string, :computer_name_data
    alias_method :computer_name, :computer_name_data

    def username_data
      field('User Name')
    end
    alias_method :username_string, :username_data
    alias_method :username, :username_data

    def secure_virtual_memory_data
      field('Secure Virtual Memory')
    end
    alias_method :secure_virtual_memory_string, :secure_virtual_memory_data
    alias_method :secure_virtual_memory, :secure_virtual_memory_data

    def system_integrity_protection_data
      field('System Integrity Protection')
    end
    alias_method :system_integrity_protection_string, :system_integrity_protection_data
    alias_method :system_integrity_protection, :system_integrity_protection_data

    def time_since_boot_data
      field('Time since boot')
    end
    alias_method :time_since_boot_string, :time_since_boot_data
    alias_method :time_since_boot, :time_since_boot_data

  end
end

if __FILE__ == $0
  MacOS::SystemProfiler.methods(false).sort.each do |methd|
    p "#{methd}: #{MacOS::SystemProfiler.send(methd)}"
  end
end
