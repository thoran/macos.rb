# MacOS/SystemProfiler.rb
# MacOS::SystemProfiler

# Description: This uses the built-in system_profiler command on MacOS to read the software overview, each field as
# system_profiler's JSON gives it, on any version of MacOS whose system_profiler takes -json.

require 'json'

module MacOS
  module SystemProfiler

    module_function

    def system_profiler_output
      `system_profiler -json SPSoftwareDataType`.force_encoding('UTF-8')
    end

    # The value system_profiler gives under a key of its JSON, such as boot_volume.
    def field(key)
      JSON.parse(system_profiler_output)['SPSoftwareDataType'].first[key]
    end
    private_class_method :field

    def system_version
      field('os_version')
    end
    alias_method :system_version_data, :system_version

    def kernel_version
      field('kernel_version')
    end
    alias_method :kernel_version_data, :kernel_version

    def boot_volume
      field('boot_volume')
    end
    alias_method :boot_volume_data, :boot_volume
    alias_method :boot_volume_string, :boot_volume

    def boot_mode
      field('boot_mode')
    end
    alias_method :boot_mode_data, :boot_mode
    alias_method :boot_mode_string, :boot_mode

    def computer_name
      field('local_host_name')
    end
    alias_method :computer_name_data, :computer_name
    alias_method :computer_name_string, :computer_name

    def user_name
      field('user_name')
    end
    alias_method :username_data, :user_name
    alias_method :username_string, :user_name
    # username too, it being the word commonly reached for.
    alias_method :username, :user_name

    def secure_virtual_memory
      field('secure_vm')
    end
    alias_method :secure_virtual_memory_data, :secure_virtual_memory
    alias_method :secure_virtual_memory_string, :secure_virtual_memory

    def system_integrity_protection
      field('system_integrity')
    end
    alias_method :system_integrity_protection_data, :system_integrity_protection
    alias_method :system_integrity_protection_string, :system_integrity_protection

    def time_since_boot
      field('uptime')
    end
    alias_method :time_since_boot_data, :time_since_boot
    alias_method :time_since_boot_string, :time_since_boot

    # The aliases as module functions too, alias_method making instance methods alone.
    module_function(
      :system_version_data,
      :kernel_version_data,
      :boot_volume_data, :boot_volume_string,
      :boot_mode_data, :boot_mode_string,
      :computer_name_data, :computer_name_string,
      :username_data, :username_string, :username,
      :secure_virtual_memory_data, :secure_virtual_memory_string,
      :system_integrity_protection_data, :system_integrity_protection_string,
      :time_since_boot_data, :time_since_boot_string
    )

  end
end
