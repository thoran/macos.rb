require_relative '../helper'
require 'MacOS/SystemProfiler'

describe MacOS::SystemProfiler do
  def with_output(output = fixture('system_profiler-SPSoftwareDataType.json'), &block)
    MacOS::SystemProfiler.stub(:system_profiler_output, output, &block)
  end

  it "gives the system's and the kernel's versions as system_profiler gives them" do
    with_output do
      sp = MacOS::SystemProfiler
      _([sp.system_version, sp.system_version_data]).must_equal(['macOS 15.8.1 (24H32)'] * 2)
      _([sp.kernel_version, sp.kernel_version_data]).must_equal(['Darwin 24.6.0'] * 2)
    end
  end

  it "gives each of the other fields as system_profiler gives it, by its method and by its aliases" do
    with_output do
      sp = MacOS::SystemProfiler
      _([sp.boot_volume, sp.boot_volume_data, sp.boot_volume_string]).must_equal(['Macintosh HD'] * 3)
      _([sp.boot_mode, sp.boot_mode_data, sp.boot_mode_string]).must_equal(['normal_boot'] * 3)
      _([sp.computer_name, sp.computer_name_data, sp.computer_name_string]).must_equal(['Example Mac'] * 3)
      _([sp.user_name, sp.username_data, sp.username_string, sp.username]).must_equal(['Example User (example)'] * 4)
      _([sp.secure_virtual_memory, sp.secure_virtual_memory_data, sp.secure_virtual_memory_string]).must_equal(['secure_vm_enabled'] * 3)
      _([sp.system_integrity_protection, sp.system_integrity_protection_data, sp.system_integrity_protection_string]).must_equal(['integrity_enabled'] * 3)
      _([sp.time_since_boot, sp.time_since_boot_data, sp.time_since_boot_string]).must_equal(['up 6:02:34:00'] * 3)
    end
  end

  it "gives nil for a field which isn't there" do
    with_output('{"SPSoftwareDataType": [{}]}') do
      _(MacOS::SystemProfiler.boot_mode).must_be_nil
    end
  end

  it "no longer interprets a field" do
    %i{system_version_string kernel_version_string major_system_version minor_system_version tiny_system_version kernel_name}.each do |name|
      _(MacOS::SystemProfiler.respond_to?(name)).must_equal(false)
    end
  end

  it "keeps its reading of a field to itself" do
    _(MacOS::SystemProfiler.respond_to?(:field)).must_equal(false)
  end
end
