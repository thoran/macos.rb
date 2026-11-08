require_relative '../helper'
require 'MacOS/DiskUtil'

describe MacOS::DiskUtil do
  def with_disks(&block)
    MacOS::DiskUtil.stub(:xml_volume_plist, fixture('diskutil-list-plist.xml'), &block)
  end

  def with_df(&block)
    MacOS::DiskUtil.stub(:`, fixture('df-k.txt'), &block)
  end

  describe "the volumes" do
    it "keeps the disks with partitions" do
      with_disks do
        _(MacOS::DiskUtil.volumes_and_partitions.map{|disk| disk['DeviceIdentifier']}).must_equal(%w{disk0 disk4})
      end
    end

    it "gives each partition's device, mount point, name and size" do
      with_disks do
        _(MacOS::DiskUtil.volumes.last).must_equal({device_id: 'disk4s1', mount_point: '/Volumes/EXAMPLE', name: 'EXAMPLE', size: 32006733824})
        _(MacOS::DiskUtil.volumes.map{|volume| volume[:device_id]}).must_equal(%w{disk0s1 disk0s2 disk4s1})
      end
    end

    it "gives those which are mounted as its external volumes" do
      with_disks do
        _(MacOS::DiskUtil.external_volumes.map{|volume| volume[:name]}).must_equal(%w{EXAMPLE})
      end
    end
  end

  describe "the free space" do
    it "gives the bytes available on a device or a volume" do
      with_df do
        _(MacOS::DiskUtil.free_bytes_for_device_id('disk4s1')).must_equal(31241024 * 1024)
        _(MacOS::DiskUtil.free_bytes_for_volume_name('EXAMPLE')).must_equal(31241024 * 1024)
      end
    end

    it "gives nil for a device which isn't there" do
      with_df do
        _(MacOS::DiskUtil.free_bytes_for_device_id('disk9s9')).must_be_nil
      end
    end
  end
end
