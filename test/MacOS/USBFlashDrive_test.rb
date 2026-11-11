require_relative '../helper'
require 'MacOS/USBFlashDrive'

describe MacOS::USBFlashDrive do
  def with_output(output, &block)
    MacOS::USBFlashDrive.stub(:raw_system_profiler_output, [output, '', nil], &block)
  end

  it "asks system_profiler for the USB devices" do
    _(MacOS::USBFlashDrive.system_profiler_usb_data_type_command).must_equal('system_profiler -json SPUSBDataType')
  end

  it "gives every flash drive's mount point, behind a hub or not, and none for a volume which isn't mounted" do
    with_output(fixture('system_profiler-SPUSBDataType.json')) do
      _(MacOS::USBFlashDrive.all_mount_points).must_equal(['/Volumes/EXAMPLE', '/Volumes/Example 2'])
    end
  end

  it "gives none where no flash drive is plugged in" do
    with_output('{"SPUSBDataType": [{"_name": "USB31Bus", "host_controller": "AppleUSBXHCI"}]}') do
      _(MacOS::USBFlashDrive.all_mount_points).must_equal([])
    end
  end

  it "keeps its walk through the devices to itself" do
    _(MacOS::USBFlashDrive.respond_to?(:volumes)).must_equal(false)
  end
end
