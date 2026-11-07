require_relative '../helper'
require 'MacOS/SystemProfiler'

describe MacOS::SystemProfiler do
  def with_output(output = fixture('system_profiler-SPSoftwareDataType.txt'), &block)
    MacOS::SystemProfiler.stub(:system_profiler_output, output, &block)
  end

  describe "the system's version" do
    it "reads it from the System Version field" do
      with_output do
        _(MacOS::SystemProfiler.system_version_data).must_equal('macOS 15.8.1 (24H32)')
        _(MacOS::SystemProfiler.system_version_string).must_equal('15.8.1')
      end
    end

    it "reads the version of an older OS X" do
      with_output("      System Version: Mac OS X 10.9.5 (13F34)\n") do
        _(MacOS::SystemProfiler.system_version_string).must_equal('10.9.5')
      end
    end

    it "gives it as a Version, and its major, minor and tiny parts" do
      with_output do
        _(MacOS::SystemProfiler.system_version).must_be_instance_of(Version)
        _(MacOS::SystemProfiler.system_version.to_s).must_equal('15.8.1')
        _(MacOS::SystemProfiler.major_system_version).must_equal('15')
        _(MacOS::SystemProfiler.minor_system_version).must_equal('8')
        _(MacOS::SystemProfiler.tiny_system_version).must_equal('1')
      end
    end
  end

  describe "the kernel" do
    it "reads its name and version" do
      with_output do
        _(MacOS::SystemProfiler.kernel_version_data).must_equal('Darwin 24.6.0')
        _(MacOS::SystemProfiler.kernel_name).must_equal('Darwin')
        _(MacOS::SystemProfiler.kernel_version_string).must_equal('24.6.0')
        _(MacOS::SystemProfiler.kernel_version.to_s).must_equal('24.6.0')
      end
    end
  end

  describe "the other fields" do
    it "reads each, by its method and by its aliases" do
      with_output do
        sp = MacOS::SystemProfiler
        _([sp.boot_volume_data, sp.boot_volume_string]).must_equal(['Macintosh HD'] * 2)
        _([sp.boot_mode_data, sp.boot_mode_string, sp.boot_mode]).must_equal(['Normal'] * 3)
        _([sp.computer_name_data, sp.computer_name_string, sp.computer_name]).must_equal(['Example Mac'] * 3)
        _([sp.username_data, sp.username_string, sp.username]).must_equal(['Example User (example)'] * 3)
        _([sp.secure_virtual_memory_data, sp.secure_virtual_memory_string, sp.secure_virtual_memory]).must_equal(['Enabled'] * 3)
        _([sp.system_integrity_protection_data, sp.system_integrity_protection_string, sp.system_integrity_protection]).must_equal(['Enabled'] * 3)
        _([sp.time_since_boot_data, sp.time_since_boot_string, sp.time_since_boot]).must_equal(['6 days, 2 hours, 34 minutes'] * 3)
      end
    end

    it "gives nil for a field which isn't there" do
      with_output('') do
        _(MacOS::SystemProfiler.boot_mode).must_be_nil
      end
    end
  end

  it "keeps its reading of a field to itself" do
    _(MacOS::SystemProfiler.respond_to?(:field)).must_equal(false)
  end
end
