# MacOS/USBFlashDrive.rb
# MacOS::USBFlashDrive

require 'json'
require 'open3'
require 'shellwords'

module MacOS
  class USBFlashDrive
    class << self

      def system_profiler_usb_data_type_command
        "system_profiler -json SPUSBDataType"
      end

      def raw_system_profiler_output
        Open3.capture3(system_profiler_usb_data_type_command)
      end

      def all_mount_points
        stdout, stderr, status = raw_system_profiler_output
        volumes(JSON.parse(stdout)['SPUSBDataType']).filter_map{|volume| volume['mount_point']}
      end

      private

      # Every volume of every device, a device behind a hub being listed under the hub's _items.
      def volumes(devices)
        devices.flat_map do |device|
          (device['Media'] || []).flat_map{|media| media['volumes'] || []} + volumes(device['_items'] || [])
        end
      end

    end # class << self
  end
end
