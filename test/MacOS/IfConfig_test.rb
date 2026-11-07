require_relative '../helper'
require 'MacOS/IfConfig'

describe MacOS::IfConfig do
  let(:output){fixture('ifconfig-a.txt')}

  def with_ifconfig(output = fixture('ifconfig-a.txt'), &block)
    MacOS::IfConfig.stub(:output, output, &block)
  end

  def interface(name)
    MacOS::IfConfig.parse(output).find{|ifconfig| ifconfig.interface == name}
  end

  describe ".parse" do
    it "makes one for each interface, in the order ifconfig lists them" do
      _(MacOS::IfConfig.parse(output).map(&:interface)).must_equal(%w{lo0 gif0 stf0 en1 en0 awdl0 bridge0 utun0 utun4})
    end

    it "reads an interface's address, netmask and broadcast address" do
      en0 = interface('en0')
      _(en0.ipv4_address).must_equal('192.0.2.114')
      _(en0.netmask).must_equal('0xffffff00')
      _(en0.broadcast_address).must_equal('192.0.2.255')
    end

    it "reads an address without a broadcast address" do
      _(interface('lo0').ipv4_address).must_equal('127.0.0.1')
      _(interface('lo0').netmask).must_equal('0xff000000')
    end

    it "reads the near end of a point-to-point address" do
      _(interface('utun4').ipv4_address).must_equal('198.51.100.250')
      _(interface('utun4').netmask).must_equal('0xffffffff')
    end

    it "reads the MAC address, status and flags" do
      en0 = interface('en0')
      _(en0.mac_address).must_equal('00:00:5e:00:53:02')
      _(en0.status).must_equal('active')
      _(en0.flags).must_include('UP')
    end

    it "reads lines with a trailing space, as older ifconfigs give them" do
      older = "en0: flags=8863<UP,BROADCAST> mtu 1500\n\tether 00:00:5e:00:53:02 \n\tinet 192.0.2.114 netmask 0xffffff00 \n"
      en0 = MacOS::IfConfig.parse(older).first
      _(en0.mac_address).must_equal('00:00:5e:00:53:02')
      _(en0.ipv4_address).must_equal('192.0.2.114')
      _(en0.netmask).must_equal('0xffffff00')
    end

    it "gives the same each time" do
      first = MacOS::IfConfig.parse(output).map(&:interface)
      _(MacOS::IfConfig.parse(output).map(&:interface)).must_equal(first)
    end

    it "gives none for output with no interfaces" do
      _(MacOS::IfConfig.parse('')).must_equal([])
    end
  end

  describe "the interfaces in each state" do
    it "lists those which are active and inactive" do
      with_ifconfig do
        _(MacOS::IfConfig.active_interfaces_names).must_equal(%w{en0 awdl0})
        _(MacOS::IfConfig.inactive_interfaces_names).must_equal(%w{en1 bridge0})
      end
    end

    it "lists those which are up: active or flagged UP, and with an address" do
      with_ifconfig do
        _(MacOS::IfConfig.up_interfaces_names).must_equal(%w{lo0 en0 utun4})
      end
    end
  end

  describe "the interfaces themselves" do
    it "lists every interface's name, and those active and inactive" do
      with_ifconfig do
        _(MacOS::IfConfig.interface_names).must_equal(%w{lo0 gif0 stf0 en1 en0 awdl0 bridge0 utun0 utun4})
        _(MacOS::IfConfig.active_interfaces.map(&:name)).must_equal(%w{en0 awdl0})
        _(MacOS::IfConfig.inactive_interfaces.map(&:name)).must_equal(%w{en1 bridge0})
      end
    end
  end

  describe "the addresses" do
    it "lists every MAC address and IPv4 address" do
      with_ifconfig do
        _(MacOS::IfConfig.mac_addresses).must_equal(%w{00:00:5e:00:53:01 00:00:5e:00:53:02 00:00:5e:00:53:03 00:00:5e:00:53:01})
        _(MacOS::IfConfig.ipv4_addresses).must_equal(%w{127.0.0.1 192.0.2.114 198.51.100.250})
      end
    end
  end

  describe "finding" do
    it "finds an interface by its name, MAC address or IPv4 address" do
      with_ifconfig do
        _(MacOS::IfConfig.find_by_interface('en0').mac_address).must_equal('00:00:5e:00:53:02')
        _(MacOS::IfConfig.find_by_mac_address('00:00:5e:00:53:03').interface).must_equal('awdl0')
        _(MacOS::IfConfig.find_by_ipv4_address('198.51.100.250').interface).must_equal('utun4')
      end
    end

    it "matches names against a Regexp, or a String taken literally" do
      with_ifconfig do
        _(MacOS::IfConfig.all_matching(/\Autun\d/).map(&:name)).must_equal(%w{utun0 utun4})
        _(MacOS::IfConfig.all_matching('en').map(&:name)).must_equal(%w{en1 en0})
        _(MacOS::IfConfig.all_matching('.')).must_equal([])
      end
    end
  end

  describe "bringing interfaces down" do
    it "brings down only those matching which are up" do
      with_ifconfig do
        commands = commands_run_by(MacOS::IfConfig) do
          _(MacOS::IfConfig.bring_down_matching_interfaces(/\Autun/)).must_equal(%w{utun4})
        end
        _(commands).must_equal([%w{sudo ifconfig utun4 down}])
      end
    end

    it "destroys an interface" do
      commands = commands_run_by(MacOS::IfConfig){MacOS::IfConfig.destroy_interface('utun4')}
      _(commands).must_equal([%w{sudo ifconfig utun4 destroy}])
    end
  end

  describe "an interface" do
    it "gives its MAC address as its Ethernet address too" do
      _(interface('en0').ethernet_address).must_equal('00:00:5e:00:53:02')
    end

    it "knows whether it's virtual" do
      _(interface('utun4').virtual?).wont_be_nil
      _(interface('en0').virtual?).must_be_nil
    end
  end

  it "keeps the raw output to itself" do
    _(MacOS::IfConfig.respond_to?(:output)).must_equal(false)
  end
end
