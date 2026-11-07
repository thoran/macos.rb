#!/usr/bin/env ruby
# MacOS::Apple80211

module MacOS
  class Apple80211
    class << self

      def airport_i
        `/System/Library/PrivateFrameworks/Apple80211.framework/Resources/airport -I`
      rescue Errno::ENOENT
        ''
      end

      def system_profiler_airport
        `system_profiler SPAirPortDataType`
      end

      # airport -I's attributes, or, where it gives none, as from macOS 14.4 on, system_profiler's.
      def attributes
        from_airport = airport_attributes
        from_airport.empty? ? system_profiler_attributes : from_airport
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

      private

      # The deprecation warning macOS 14.4 and later print, in place of the attributes, left out.
      def airport_attributes
        airport_i.split("\n").inject({}) do |a, line|
          if line && line.match(/: .+/)
            k, v = line.split(': ')
            a[k.strip] = v.gsub('"', '')
          end
          a
        end.reject{|k, _| k == 'WARNING'}
      end

      # The current network's fields, with its name as SSID where macOS doesn't redact it, and its Channel and Security as
      # channel and link auth.
      def system_profiler_attributes
        lines = system_profiler_airport.lines
        start = lines.index{|line| line.strip == 'Current Network Information:'} or return {}
        name_line = lines[start + 1].to_s
        return {} unless name_line.strip.end_with?(':')
        depth = name_line[/\A */].size
        fields = lines[(start + 2)..].take_while{|line| line[/\A */].size > depth && !line.strip.empty?}
        attributes = fields.to_h{|line| line.strip.split(': ', 2)}
        name = name_line.strip.chomp(':')
        attributes['SSID'] = name unless name == '<redacted>'
        attributes['channel'] = attributes['Channel'] if attributes['Channel']
        attributes['link auth'] = attributes['Security'] if attributes['Security']
        attributes
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
