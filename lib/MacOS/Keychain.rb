#!/usr/bin/env ruby
# MacOS::Keychain

# 20201218, 20210206
# 0.0.0

module MacOS
  class Keychain
    class << self
 
      def find_generic_password(key)
        `security find-generic-password -ga #{key}`
      end

      def wifi_password(wifi_ssid)
        find_generic_password(wifi_ssid).match(/password: (.+^)/)
      end

    end # class << self
  end
end

if __FILE__ == $0
  wifi_ssid = ARGV[0]
  puts MacOS::Keychain.wifi_password(wifi_ssid)
end
