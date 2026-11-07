require_relative '../helper'
require 'MacOS/IfConfig'
require 'MacOS/VPN'

describe MacOS::VPN do
  it "is up where a tunnel interface is up" do
    MacOS::IfConfig.stub(:output, fixture('ifconfig-a.txt')) do
      _(MacOS::VPN.up?.interface).must_equal('utun4')
    end
  end

  it "isn't where no tunnel interface has an address" do
    without_tunnel = fixture('ifconfig-a.txt').sub(/^\tinet 198\.51\.100\.250 .+\n/, '')
    MacOS::IfConfig.stub(:output, without_tunnel) do
      _(MacOS::VPN.up?).must_be_nil
    end
  end
end
