# MacOS/DiskUtil.rb
# MacOS::DiskUtil

require 'plist'

module MacOS
  class DiskUtil

    class << self
      def xml_volume_plist
        `diskutil list -plist`
      end

      def volume_plist
        Plist.parse_xml(xml_volume_plist)
      end

      def volumes_and_partitions
        volume_plist["AllDisksAndPartitions"].select do |dp|
          !dp["Partitions"].empty?
        end
      end

      def volume_partitions(volume)
        volume["Partitions"]
      end

      def volumes
        volumes_and_partitions.collect do |volume|
          volume_partitions(volume).collect do |partition|
            {
              device_id: partition["DeviceIdentifier"],
              mount_point: partition["MountPoint"],
              name: partition["VolumeName"],
              size: partition["Size"],
            }
          end
        end.flatten.compact
      end

      def external_volumes
        volumes.reject{|v| v[:mount_point].nil?}
      end

      def free_bytes_for_device_id(device_id)
        `df`.split("\n").detect do |partition_data|
          if partition_data.split.first.match(device_id)
            return partition_data.split[2]
          end
        end
      end

      def free_bytes_for_volume_name(volume_name)
        `df`.split("\n").detect do |partition_data|
          if partition_data.split.last.match(volume_name)
            return partition_data.split[2]
          end
        end
      end
    end # class << self

  end
end
