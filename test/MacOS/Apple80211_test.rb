require_relative '../helper'
require 'MacOS/Apple80211'

describe MacOS::Apple80211 do
  let(:wifi){fixture('system_profiler-SPAirPortDataType.txt')}

  def with_sources(airport, system_profiler = fixture('system_profiler-SPAirPortDataType.txt'), &block)
    MacOS::Apple80211.stub(:airport_i, airport) do
      MacOS::Apple80211.stub(:system_profiler_airport, system_profiler, &block)
    end
  end

  describe "where airport -I reports, as before macOS 14.4" do
    it "reads its attributes" do
      with_sources(fixture('airport-I.txt')) do
        attributes = MacOS::Apple80211.attributes
        _(attributes['BSSID']).must_equal('00:00:5e:00:53:20')
        _(attributes['agrCtlRSSI']).must_equal('-52')
        _(attributes['op mode']).must_equal('station')
      end
    end

    it "gives the channel, SSID and link authentication" do
      with_sources(fixture('airport-I.txt')) do
        _(MacOS::Apple80211.channel).must_equal('36,80')
        _(MacOS::Apple80211.ssid).must_equal('ExampleNet')
        _(MacOS::Apple80211.link_auth).must_equal('wpa2-psk')
      end
    end
  end

  describe "where airport -I gives only its deprecation, as from macOS 14.4 on" do
    it "reads the current network from system_profiler instead" do
      with_sources(fixture('airport-I-deprecated.txt')) do
        attributes = MacOS::Apple80211.attributes
        _(attributes['PHY Mode']).must_equal('802.11ax')
        _(attributes['Signal / Noise']).must_equal('-52 dBm / -94 dBm')
        _(attributes.keys).wont_include('WARNING')
      end
    end

    it "gives its channel and security as system_profiler gives them" do
      with_sources(fixture('airport-I-deprecated.txt')) do
        _(MacOS::Apple80211.channel).must_equal('36 (5GHz, 80MHz)')
        _(MacOS::Apple80211.link_auth).must_equal('WPA2 Personal')
      end
    end

    it "gives no SSID where macOS redacts the network's name" do
      with_sources(fixture('airport-I-deprecated.txt')) do
        _(MacOS::Apple80211.ssid).must_be_nil
      end
    end

    it "gives the SSID where macOS doesn't redact it" do
      with_sources(fixture('airport-I-deprecated.txt'), wifi.sub('            <redacted>:', '            ExampleNet:')) do
        _(MacOS::Apple80211.ssid).must_equal('ExampleNet')
      end
    end

    it "gives nothing where there's no current network" do
      with_sources(fixture('airport-I-deprecated.txt'), "Wi-Fi:\n\n      Interfaces:\n        en0:\n          Status: Off\n") do
        _(MacOS::Apple80211.attributes).must_equal({})
        _(MacOS::Apple80211.channel).must_be_nil
      end
    end
  end

  describe "where airport isn't there" do
    it "reads system_profiler" do
      missing = ->(command){raise Errno::ENOENT, command}
      MacOS::Apple80211.stub(:`, missing) do
        _(MacOS::Apple80211.airport_i).must_equal('')
      end
      with_sources('') do
        _(MacOS::Apple80211.channel).must_equal('36 (5GHz, 80MHz)')
      end
    end
  end
end
