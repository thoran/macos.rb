#!/usr/bin/env ruby
# MacOS::Keychain

# 20210220
# 0.1.1

require 'open3'
require 'shellwords'

module MacOS
  class Keychain
    class << self

      def find_generic_password_command(key)
        "security find-generic-password -ga #{Shellwords.escape(key)}"
      end

      def find_generic_password(key)
        Open3.capture3(find_generic_password_command(key))
      end

      def wifi_password(wifi_ssid)
        stdout, stderr, status = find_generic_password(wifi_ssid)
        stderr.match(/password: "(.+)"/)[1]
      end

    end # class << self
  end
end

if __FILE__ == $0
  wifi_ssid = ARGV[0]
  puts MacOS::Keychain.find_generic_password(wifi_ssid)
  puts MacOS::Keychain.wifi_password(wifi_ssid)
end
