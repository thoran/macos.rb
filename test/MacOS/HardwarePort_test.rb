require_relative '../helper'
require 'MacOS/HardwarePort'

describe MacOS::HardwarePort do
  def with_ports(&block)
    MacOS::HardwarePort.stub(:output, fixture('networksetup-listallhardwareports.txt'), &block)
  end

  describe ".parse" do
    it "makes one for each hardware port networksetup lists" do
      ports = MacOS::HardwarePort.parse(fixture('networksetup-listallhardwareports.txt'))
      _(ports.map(&:interface)).must_equal(%w{en4 en5 en6 en8 bridge0 en0 en1 en2 en3})
    end

    it "reads each port's name, device and Ethernet address" do
      wifi = MacOS::HardwarePort.parse(fixture('networksetup-listallhardwareports.txt')).find{|port| port.device == 'en0'}
      _(wifi.hardware_port).must_equal('Wi-Fi')
      _(wifi.name).must_equal('Wi-Fi')
      _(wifi.ethernet_address).must_equal('00:00:5e:00:53:08')
      _(wifi.mac_address).must_equal('00:00:5e:00:53:08')
    end
  end

  describe "finding" do
    it "finds a port by its interface, its name or its MAC address" do
      with_ports do
        _(MacOS::HardwarePort.find_by_interface('en0').name).must_equal('Wi-Fi')
        _(MacOS::HardwarePort.find_by_device('bridge0').name).must_equal('Thunderbolt Bridge')
        _(MacOS::HardwarePort.find_by_name('Wi-Fi').interface).must_equal('en0')
        _(MacOS::HardwarePort.find_by_hardware_port('Thunderbolt 2').interface).must_equal('en2')
        _(MacOS::HardwarePort.find_by_mac_address('00:00:5e:00:53:04').interface).must_equal('en4')
        _(MacOS::HardwarePort.find_by_ethernet_address('00:00:5e:00:53:04').interface).must_equal('en4')
      end
    end

    it "finds nothing for a port which isn't there" do
      with_ports do
        _(MacOS::HardwarePort.find_by_name('Nowhere')).must_be_nil
      end
    end
  end

  it "keeps the raw output to itself" do
    _(MacOS::HardwarePort.respond_to?(:output)).must_equal(false)
  end
end
