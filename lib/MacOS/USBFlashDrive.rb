# MacOS/USBFlashDrive.rb
# MacOS::USBFlashDrive

require 'open3'
require 'shellwords'

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
        stdout.scan(/Mount Point: (.+)$/).flatten
      end

    end # class << self
  end
end
