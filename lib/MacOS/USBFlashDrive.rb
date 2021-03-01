#!/usr/bin/env ruby
# MacOS::USBFlashDrive

# 20210301
# 0.0.0

require 'open3'
require 'shellwords'
require 'Thoran/String/Captures/captures'

module MacOS
  class USBFlashDrive
    class << self

      def system_profiler_usb_data_type_command
        "system_profiler SPUSBDataType"
      end

      def raw_system_profiler_output
        Open3.capture3(system_profiler_usb_data_type_command)
      end

      def all_mount_points
        stdout, stderr, status = raw_system_profiler_output
        stdout.captures(/Mount Point: (.+)$/)
      end

    end # class << self
  end
end

if __FILE__ == $0
  puts MacOS::USBFlashDrive.system_profiler_usb_data_type_command
  puts MacOS::USBFlashDrive.raw_system_profiler_output
  puts MacOS::USBFlashDrive.all_mount_points
end
