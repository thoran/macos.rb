#!/usr/bin/env ruby
# MacOS::Apple80211

module MacOS
  class Apple80211
    class << self

      def airport_i
        `/System/Library/PrivateFrameworks/Apple80211.framework/Resources/airport -I`
      end

      def attributes
        airport_i.split("\n").inject({}) do |a, line|
          if line && line.match(/: .+/)
            k, v = line.split(': ')
            a[k.strip] = v.gsub('"', '')
          end
          a
        end
      end

      def channel
        attributes['channel']
      end

      def ssid
        attributes['SSID']
      end

      def link_auth
        attributes['link auth']
      end

    end # class << self
  end
end

if __FILE__ == $0
  p MacOS::Apple80211.attributes
  p MacOS::Apple80211.channel
  p MacOS::Apple80211.ssid
  p MacOS::Apple80211.link_auth
end
