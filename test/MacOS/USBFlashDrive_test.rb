require_relative '../helper'
require 'MacOS/USBFlashDrive'

describe MacOS::USBFlashDrive do
  it "asks system_profiler for the USB devices" do
    _(MacOS::USBFlashDrive.system_profiler_usb_data_type_command).must_equal('system_profiler SPUSBDataType')
  end

  it "gives every flash drive's mount point" do
    MacOS::USBFlashDrive.stub(:raw_system_profiler_output, [fixture('system_profiler-SPUSBDataType.txt'), '', nil]) do
      _(MacOS::USBFlashDrive.all_mount_points).must_equal(['/Volumes/EXAMPLE', '/Volumes/Example 2'])
    end
  end

  it "gives none where no flash drive is mounted" do
    MacOS::USBFlashDrive.stub(:raw_system_profiler_output, ["USB:\n", '', nil]) do
      _(MacOS::USBFlashDrive.all_mount_points).must_equal([])
    end
  end
end
